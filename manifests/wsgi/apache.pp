# == Class: apps_site::plugins::glare
#
class apps_site::wsgi::apache (
  $servername = $::fqdn,
  $port       = 80,
  $bind_ip    = undef,
  $docroot    = undef,
) inherits apps_site::params {


  $real_docroot = $docroot ? {
    undef   => $apps_site::params::app_catalog_dir,
    default => $docroot,
  }

  class { '::apache':
    mpm_module       => false,
    default_vhost    => false,
    purge_configs    => false,
  }

  ::apache::vhost { 'openstack-app-catalog':
    servername                  => $servername,
    port                        => $port,
    ip                          => $bind_ip,
    docroot                     => $real_docroot,
    priority                    => '50',
    access_log_file             => 'app_catalog_access.log',
    error_log_file              => 'app_catalog_error.log',
    wsgi_script_aliases         => hash(['/', "${real_docroot}/wsgi.py"]),
    wsgi_daemon_process         => $apps_site::params::wsgi_group,
    wsgi_daemon_process_options => {
      processes => $apps_site::params::wsgi_processes,
      threads   => $apps_site::params::wsgi_threads,
      user      => $apps_site::params::wsgi_user,
      group     => $apps_site::params::wsgi_group,
    },
  }

}
