$domain_name = '172.16.43.253'
$port = 8000
$glare_url = 'http://127.0.0.1:9494'
$memcache_server = '127.0.0.1:11211'
$import_assets = false
$without_glare = true

class { '::apps_site::catalog':
  domain          => $domain_name,
  port            => $port,
  glare_url       => $glare_url,
  memcache_server => $memcache_server,
  without_glare   => $without_glare,
}

unless $without_glare {

  class { '::apps_site::wsgi::apache':
    servername => $domain_name,
    http_port  => $port,
  }

  class { '::apps_site::plugins::glare':
    glare_url     => $glare_url,
    import_assets => $import_assets,
  }
}
