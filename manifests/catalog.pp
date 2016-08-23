class apps_site::catalog (
  $settings_dir = '/etc/app-catalog',
) {

  include apps_site

  file { $settings_dir:
    ensure => 'directory',
  }

  file { "${settings_dir}/local_settings.py":
    ensure  => 'present',
    content => template('apps_site/local_settings.erb'),
    require => File[$settings_dir],
  }

  exec { 'app-catalog-collect-static' :
    command     => "app-catalog-manage collectstatic --noinput",
    path        => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    refreshonly => true,
    subscribe   => [Package['openstack-app-catalog'], File["${settings_dir}/local_settings.py"]],
  }

  exec { 'app-catalog-compress' :
    command     => "app-catalog-manage compress --force",
    path        => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    refreshonly => true,
    subscribe   => [Package['openstack-app-catalog'], File["${settings_dir}/local_settings.py"]],
  }
}
