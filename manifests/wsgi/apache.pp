# == Class: apps_site::wsgi::apache
#
class apps_site::wsgi::apache (
  $servername   = $::fqdn,
  $http_port    = 80,
  $https_port   = 443,
  $ssl_cert     = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $ssl_key      = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $ssl_ca       = '/etc/ssl/certs/ca-certificates.crt',
  $bind_ip      = undef,
  $settings_dir = '/etc/openstack-catalog',
) inherits ::apps_site::params {

  class { '::apache':
    mpm_module    => false,
    default_vhost => false,
    purge_configs => false,
  }

  include ::apache::mod::ssl

  ::apache::vhost { 'openstack-app-catalog':
    servername                  => $servername,
    port                        => $http_port,
    ip                          => $bind_ip,
    redirect_status             => 'permanent',
    redirect_dest               => "https://${servername}/",
    docroot                     => '/var/www',
    priority                    => '50',
    access_log_file             => 'app_catalog_access.log',
    error_log_file              => 'app_catalog_error.log',
    setenv                      => ["LOCAL_SETTINGS_PATH ${settings_dir}"],
    aliases                     => [{
      alias => '/static',
      path  => "${apps_site::params::app_catalog_dir}/web/static",
    }],
    wsgi_script_aliases         => hash(['/', "${apps_site::params::app_catalog_dir}/wsgi.py"]),
    wsgi_daemon_process         => $apps_site::params::wsgi_group,
    wsgi_process_group          => $apps_site::params::wsgi_group,
    wsgi_daemon_process_options => {
      processes => $apps_site::params::wsgi_processes,
      threads   => $apps_site::params::wsgi_threads,
      user      => $apps_site::params::wsgi_user,
      group     => $apps_site::params::wsgi_group,
    },
  }

  ::apache::vhost { 'openstack-app-catalog-ssl':
    ensure                      => 'present',
    ssl                         => true,
    servername                  => $servername,
    port                        => $https_port,
    ip                          => $bind_ip,
    docroot                     => '/var/www',
    priority                    => '50',
    access_log_file             => 'app_catalog_ssl_access.log',
    error_log_file              => 'app_catalog_ssl_error.log',
    ssl_cert                    => $ssl_cert,
    ssl_key                     => $ssl_key,
    ssl_ca                      => $ssl_ca,
    setenv                      => ["LOCAL_SETTINGS_PATH ${settings_dir}"],
    aliases                     => [{
      alias => '/static',
      path  => "${apps_site::params::app_catalog_dir}/web/static",
    }],
    wsgi_script_aliases         => hash(['/', "${apps_site::params::app_catalog_dir}/wsgi.py"]),
    wsgi_daemon_process         => "${apps_site::params::wsgi_group}-ssl",
    wsgi_process_group          => "${apps_site::params::wsgi_group}-ssl",
    wsgi_daemon_process_options => {
      processes => $apps_site::params::wsgi_processes,
      threads   => $apps_site::params::wsgi_threads,
      user      => $apps_site::params::wsgi_user,
      group     => $apps_site::params::wsgi_group,
    },
  }
}
