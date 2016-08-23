class apps_site::params {
  $wsgi_processes = 2
  $wsgi_threads   = 4
  case $::osfamily {
    'Debian': {
      $wsgi_user                   = 'www-data'
      $wsgi_group                  = 'www-data'
      $app_catalog_dir             = '/usr/local/lib/python2.7/dist-packages/openstack_catalog/'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name}")
    }
  }
}
