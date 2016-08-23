# == Class: apps_site::plugins::glare
#
class apps_site::plugins::glare (
  $glare_endpoint = 'http://127.0.0.1:9494/',
  $assets_file    = undef,
  $import_assets  = false,
) inherits apps_site::params {


  $real_assets_file = $assets_file ? {
    undef   => "${apps_site::params::app_catalog_dir}/web/static/assets.yaml",
    default => $assets_file,
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

  if $import_assets {
    exec { 'import-glare-assets' :
      command   => "app-catalog-import-assets --glare_url ${glare_endpoint} --assets_file ${real_assets_file}",
      path      => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    }
  }

}
