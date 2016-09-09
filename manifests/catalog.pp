# class: apps_site::catalog
#

class apps_site::catalog (
  $settings_dir    = '/etc/openstack-catalog',
  $memcache_server = '127.0.0.1:11211',
  $domain          = $::fqdn,
  $assets_file     = undef,
  $import_assets   = true,
  $glare_url       = 'http://127.0.0.1:9494/'
) {

  #settings_dir should be set /etc/openstack-catalog
  #currently app-catalog will not use env variables properly
  file { $settings_dir:
    ensure => 'directory',
  }

  file { "${settings_dir}/local_settings.py":
    ensure  => 'present',
    content => template('apps_site/local_settings_glare.erb'),
    require => File[$settings_dir],
  }

  exec { 'app-catalog-collect-static' :
    command     => 'app-catalog-manage collectstatic --noinput',
    path        => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    refreshonly => true,
    subscribe   => [Package['openstack-app-catalog'], File["${settings_dir}/local_settings.py"]],
  }

  exec { 'app-catalog-compress' :
    command     => 'app-catalog-manage compress --force',
    path        => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    refreshonly => true,
    subscribe   => [Package['openstack-app-catalog'], File["${settings_dir}/local_settings.py"]],
  }

  if $import_assets {

    $real_assets_file = $assets_file ? {
      undef   => "${apps_site::params::app_catalog_dir}/web/static/assets.yaml",
      default => $assets_file,
    }

    exec { 'import-glare-assets' :
      command => "app-catalog-import-assets --glare_url ${glare_url} --assets_file ${real_assets_file}",
      path    => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
      require => [Package['openstack-app-catalog'], Exec['app-catalog-compress']],
    }
  }
}
