class apps_site::catalog (
  $settings_dir    = '/etc/openstack-catalog',
  $memcache_server = '127.0.0.1:11211',
  $domain          = $::fqdn,
  $port            = 80,
  $glare_url       = 'http://127.0.0.1:9494',
  $from_repo       = false,
  $repo            = undef,
  $branch          = 'master,
) {

  class { 'apps_site':
    from_repo => $from_repo,
    repo      => $repo,
    branch    => $branch
  }

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
}
