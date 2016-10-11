# class: apps_site::plugins::glare
#
class apps_site::plugins::glare (
  $vhost_name                = $::fqdn,
  $memcache_server           = '127.0.0.1:11211',
  $cookie_name               = 's.aoo',
  $use_ssl                   = false,
  $ssl_cert_file_content     = undef,
  $ssl_key_file_content      = undef,
  $ssl_ca_file_content       = undef,
  $ssl_cert_file_location    = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $ssl_key_file_location     = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $ssl_ca_file_location      = '/etc/ssl/certs/ca-certificates.crt',
) inherits ::apps_site::params {

  package { 'glare_dev':
    ensure   => present,
    provider => 'pip',
  }

  service { 'glare-api':
    provider => base,
    ensure   => 'running',
    start    => '/usr/local/bin/glare-api --config-file /usr/local/etc/glare/glare.conf',
    restart  => 'killall glare-api; /usr/local/bin/glare-api --config-file /usr/local/etc/glare/glare.conf',
    stop     => 'killall glare-api',
  }

  Package['glare_dev'] -> Service['glare-api']
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
