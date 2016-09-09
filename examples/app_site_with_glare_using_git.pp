#if you want to install app_site with glare support via git, memcache installed on localhost
$vhost_name = $::fqdn
$without_glare = false
$glare_server = '127.0.0.1:9494'
$memcache_server = '127.0.0.1:11211'
$repo_url = 'https://github.com/openstack/app-catalog.git'
$commit = 'master'
$use_ssl = false

if $use_ssl {
  $glare_url = "https://${glare_server}"
}else{
  $glare_url = "http://${glare_server}"
}

#installation with importing assets
$import_assets = true

class { '::apps_site':
  without_glare   => $without_glare,
  glare_url       => $glare_url,
  memcache_server => $memcache_server,
  use_pip         => false,
  use_git         => true,
  repo_url        => $repo_url,
  commit          => $commit,
}

class { '::apps_site::plugins::glare':
  glare_url       => $glare_url,
  memcache_server => $memcache_server,
  vhost_name      => $vhost_name,
}

class { '::apps_site::wsgi::apache':
  use_ssl    => $use_ssl,
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
