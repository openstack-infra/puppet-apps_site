# == Class: apps_site
#
class apps_site (
  $vhost_name = $::fqdn,
  $root_dir = '/opt/apps_site',
  $serveradmin = "webmaster@${::domain}",

  $commit = 'master',
) {

  if !defined(Package['git']) {
    package { 'git':
      ensure => present
    }
  }

  vcsrepo { $root_dir:
    ensure   => latest,
    provider => git,
    revision => $commit,
    source   => 'https://git.openstack.org/stackforge/apps-catalog.git',
    require  => [
      Package['git'],
    ]
  }

  include ::httpd

  ::httpd::vhost { $vhost_name:
    port       => 80,
    docroot    => "${root_dir}/openstack_catalog/web",
    priority   => '50',
    template   => 'apps_site/vhost.erb',
    vhost_name => $vhost_name,
  }

  httpd_mod { 'headers':
    ensure => present
  }

  httpd_mod { 'rewrite':
    ensure => present
  }

  httpd_mod { 'deflate':
    ensure => present
  }

  if ! defined(Package['python-yaml']) {
    package { 'python-yaml':
      ensure => present,
    }
  }

  if ! defined(Package['zopfli']) {
    package { 'zopfli':
      ensure => present,
    }
  }

  file { "${root_dir}/openstack_catalog/web/api":
    ensure => directory,
  }

  file { "${root_dir}/openstack_catalog/web/api/v1":
    ensure => directory,
  }

  exec { 'make_assets_json' :
    command     => "${root_dir}/tools/update_assets.sh",
    path        => '/usr/local/bin:/usr/bin:/bin',
    refreshonly => true,
    subscribe   => Vcsrepo[$root_dir],
  }

}
