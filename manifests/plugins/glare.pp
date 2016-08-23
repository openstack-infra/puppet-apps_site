# == Class: apps_site::plugins::glare
#
class apps_site::plugins::glare (
  $glare_endpoint = 'http://127.0.0.1:9494/',
  $assets_file = '/opt/apps_site/openstack_catalog/web/static/assets.yaml',
) {

  $install_dir = '/usr/local/lib/python2.7/dist-packages/openstack_catalog/'

  if ! defined(Package['python-pip']) {
    package { 'python-pip':
      ensure => present,
    }
  }

  # When glare app-catalog plugin will be delivered as package
  # change exec to package { provider => 'pip'}
  exec { 'install-glare-plugin' :
    command     => "pip install ${install_dir}/contrib/glare/",
    path        => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
  }

  exec { 'install-glare-assets' :
    command   => "python ${install_dir}/contrib/move_to_glare_10.py --glare_url ${glare_endpoint} --assets_file ${assets_file}"
    path      => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    subscribe => Exec['install-glare-plugin'],
  }

}
