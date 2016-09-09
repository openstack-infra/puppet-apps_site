$vhost_name = $::fqdn
$glare_url  = 'http://127.0.0.1:9494'

class { '::apps_site':
  vhost_name => $vhost_name,
  glare_url  => $glare_url
}

class { '::apps_site::wsgi::apache':
  servername => $vhost_name,
}

class { '::apps_site::plugins::glare':
  glare_url  => $glare_url,
}
