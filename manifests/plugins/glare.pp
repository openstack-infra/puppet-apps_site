# class: apps_site::plugins::glare
#
class apps_site::plugins::glare (
  $glare_url        = 'http://127.0.0.1:9494/',
  $vhost_name       = $::fqdn,
  $memcache_server  = '127.0.0.1:11211',
  $cookie_name      = 's.aoo',
) inherits ::apps_site::params {

  include ::glare::params
  include ::glare::db::sync

  #at the moment the package is located in the experimental repository
  #for debian, should be removed when it will be switched to stable
  if $::os_package_type == 'debian'{
    Package<|title == 'glare'|> {
      name            => 'glare-api',
      install_options => ['-t', 'experimental'],
    }
  }

  glare_paste_ini {
    'filter:session/paste.filter_factory':
      value => 'openstack_app_catalog.middlewares:SessionMiddleware.factory';
    'filter:session/memcached_server':
      value => $memcache_server;
    'filter:session/session_cookie_name':
      value => $cookie_name;
    'filter:cors/allowed_origin':
      value => "http://${vhost_name}";
  }

  file { "/etc/glare/glare-policy.json":
    content => "{\n  \"context_is_admin\": \"role:app-catalog-core\"  \n}",
    require => Package[ 'glare' ],
  }

  glare_config {
     'oslo_policy/policy_file': value => 'glare-policy.json';
  }

  class { '::glare':
    pipeline               => 'session',
    allow_anonymous_access => true,
    auth_strategy          => 'none',
  }
}
