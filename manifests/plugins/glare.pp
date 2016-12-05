# class: apps_site::plugins::glare
#
class apps_site::plugins::glare (
  $vhost_name                = $::fqdn,
  $memcache_server           = '127.0.0.1:11211',
  $memcached_listen_ip       = '127.0.0.1',
  $cookie_name               = 's.aoo',
  $use_ssl                   = false,
  $ssl_cert_file_content     = undef,
  $ssl_key_file_content      = undef,
  $ssl_ca_file_content       = undef,
  $ssl_cert_file_location    = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $ssl_key_file_location     = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $ssl_ca_file_location      = '/etc/ssl/certs/ca-certificates.crt',
  $extra_params              = '--config-file /usr/local/etc/glare/glare.conf'
) inherits ::apps_site::params {

  class { '::memcached':
    listen_ip => $memcached_listen_ip,
  }

# TODO(iudovichenko): Remove below block and its resource from install
#                     chain once kombu package will be fixed.
  package { 'kombu==3.0.37,>=4.0.2':
    ensure   => present,
    provider => 'pip',
  }

  package { 'glare_dev':
    ensure   => present,
    provider => 'pip',
  }

  service { 'glare-api':
    ensure   => 'running',
    provider => base,
    start    => "nohup glare-api ${extra_params} &",
    restart  => "killall glare-api; nohup glare-api ${extra_params} &",
    stop     => 'killall glare-api',
  }

  exec { 'glare-db-sync':
    command     => "glare-db-manage ${extra_params} upgrade",
    path        => [ '/bin/', '/usr/bin/' , '/usr/local/bin' ],
    refreshonly => true,
    try_sleep   => 5,
    tries       => 10,
    logoutput   => on_failure,
  }

  Class['memcached'] ->
    Package['kombu==3.0.37,>=4.0.2'] ->
      Package['glare_dev'] ~>
        Exec['glare-db-sync'] ->
          Service['glare-api']

#  include ::glare::params
#  include ::glare::db::sync
#
#  if $use_ssl {
#    if $ssl_cert_file_content != undef {
#      file { $ssl_cert_file_location:
#        owner   => 'root',
#        group   => 'root',
#        mode    => '0640',
#        content => $ssl_cert_file_content,
#      }
#    }
#
#    if $ssl_key_file_content != undef {
#      file { $ssl_key_file_location:
#        owner   => 'root',
#        group   => 'ssl-cert',
#        mode    => '0640',
#        content => $ssl_key_file_content,
#      }
#    }
#
#    if $ssl_ca_file_content != undef {
#      file { $ssl_ca_file_location:
#        owner   => 'root',
#        group   => 'root',
#        mode    => '0640',
#        content => $ssl_ca_file_content,
#      }
#    }
#  }
#
#  #at the moment the package is located in the experimental repository
#  #for debian, should be removed when it will be switched to stable
#  if $::os_package_type == 'debian'{
#    Package<|title == 'glare'|> {
#      name            => 'glare-api',
#      install_options => ['-t', 'experimental'],
#    }
#  }
#
#   glare_paste_ini {
#     'filter:session/paste.filter_factory':
#       value => 'openstack_app_catalog.middlewares:SessionMiddleware.factory';
#     'filter:session/memcached_server':
#       value => $memcache_server;
#     'filter:session/session_cookie_name':
#       value => $cookie_name;
#     'filter:cors/allowed_origin':
#       value => "http://${vhost_name}";
#   }
#
#   file { '/etc/glare/glare-policy.json':
#     content => "{\n  \"context_is_admin\": \"role:app-catalog-core\"  \n}",
#     require => Package[ 'glare' ],
#   }
#
#   glare_config {
#     'oslo_policy/policy_file': value => 'glare-policy.json';
#   }
#
#   if $use_ssl {
#     class { '::glare':
#       pipeline               => 'session',
#       allow_anonymous_access => true,
#       auth_strategy          => 'none',
#       cert_file              => $ssl_cert_file_location,
#       key_file               => $ssl_key_file_location,
#       ca_file                => $ssl_ca_file_location,
#     }
#   }else{
#      class { '::glare':
#        pipeline               => 'session',
#        allow_anonymous_access => true,
#        auth_strategy          => 'none',
#      }
#   }
}
