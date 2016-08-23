class apps_site::catalog (
) {

  include apps_site

  exec { 'app-catalog-collect-static' :
    command   => "app-catalog-manage collectstatic --noinput",
    path      => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    refreshonly => true,
    subscribe   => Package['openstack-app-catalog'],
  }

  exec { 'app-catalog-compress' :
    command     => "app-catalog-manage compress --force",
    path        => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    refreshonly => true,
    subscribe   => Package['openstack-app-catalog'],
  }
}
