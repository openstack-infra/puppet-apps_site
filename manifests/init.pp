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

  include apache
  include apt

  apache::vhost { $vhost_name:
    port       => 80,
    docroot    => "${root_dir}/openstack_catalog/web",
    priority   => '50',
    template   => 'apps_site/vhost.erb',
    vhost_name => $vhost_name,
  }

  a2mod { 'headers':
    ensure => present
  }

  if ! defined(Package['python-yaml']) {
    package { 'python-yaml':
      ensure => present,
    }
  }

  exec { 'make_glance_json' :
    command   => "python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout)' < ${root_dir}/openstack_catalog/web/static/glance_images.yaml > ${root_dir}/openstack_catalog/web/static/glance_images.json",
    path      => '/usr/local/bin:/usr/bin:/bin',
    subscribe => Vcsrepo[$root_dir],
  }

  exec { 'make_heat_json' :
    command   => "python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout)' < ${root_dir}/openstack_catalog/web/static/heat_templates.yaml > ${root_dir}/openstack_catalog/web/static/heat_templates.json",
    path      => '/usr/local/bin:/usr/bin:/bin',
    subscribe => Vcsrepo[$root_dir],
  }

  exec { 'make_murano_json' :
    command   => "python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout)' < ${root_dir}/openstack_catalog/web/static/murano_apps.yaml > ${root_dir}/openstack_catalog/web/static/murano_apps.json",
    path      => '/usr/local/bin:/usr/bin:/bin',
    subscribe => Vcsrepo[$root_dir],
  }


}
