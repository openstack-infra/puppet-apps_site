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

  include ::apache

  ::apache::vhost { $vhost_name:
    port       => 80,
    docroot    => "${root_dir}/openstack_catalog/web",
    priority   => '50',
    template   => 'apps_site/vhost.erb',
    vhost_name => $vhost_name,
  }

}
