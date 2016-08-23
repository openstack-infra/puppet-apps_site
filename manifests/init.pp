# == Class: apps_site
#
class apps_site (
) {

  if ! defined(Package['python-yaml']) {
    package { 'python-yaml':
      ensure => present,
    }
  }

  if ($::lsbdistcodename == 'trusty') {
    if ! defined(Package['zopfli']) {
      package { 'zopfli':
        ensure => present,
      }
    }
  }

  if ! defined(Package['python-pip']) {
    package { 'python-pip':
      ensure => present,
    }
  }

  if ! defined(Package['openstack-app-catalog']) {
    package {'openstack-app-catalog':
      provider => pip,
      ensure   => 'latest',
    }
  }
}
