# == Class: apps_site
#
class ::apps_site (
) {

  if ($::lsbdistcodename == 'trusty') {
    if ! defined(Package['zopfli']) {
      package { 'zopfli':
        ensure => present,
        before => Package['openstack-app-catalog'],
      }
    }
  }

  if ! defined(Package['python-pip']) {
    package { 'python-pip':
      ensure => present,
      before => Package['openstack-app-catalog'],
    }
  }

  if ! defined(Package['openstack-app-catalog']) {
    package {'openstack-app-catalog':
      provider => pip,
      ensure   => 'latest',
    }
  }
}
