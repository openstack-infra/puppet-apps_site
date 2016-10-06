#if you want to install app_site with glare support via pip, memcache installed on localhost
$vhost_name = $::fqdn
$without_glare = false
$glare_url = 'http://127.0.0.1:9494'
$memcache_server = '127.0.0.1:11211'

#installation with importing assets
$import_assets = true

class { '::apps_site':
  without_glare   => $without_glare,
  glare_url       => $glare_url,
  memcache_server => $memcache_server,
}

class { '::apps_site::plugins::glare':
  glare_url       => $glare_url,
  memcache_server => $memcache_server,
  vhost_name      => $vhost_name,
}

class { '::apps_site::wsgi::apache':
  servername => $vhost_name,
}

class { '::apps_site::catalog':
  import_assets   => $import_assets,
  domain          => $vhost_name,
  glare_url       => $glare_url,
  memcache_server => $memcache_server,
}

Class['::apps_site'] ->
  Class['::apps_site::plugins::glare'] ->
    Anchor['glare::service::end'] ->
      Class['::apps_site::wsgi::apache'] ->
        Class['::apps_site::catalog']
