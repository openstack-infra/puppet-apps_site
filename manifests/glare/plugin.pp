# == Class: apps_site::glare::plugin
#
class apps_site::glare::plugin (
  $install_dir = '/usr/local/lib/python2.7/dist-packages/openstack_catalog/',
) {

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

}
