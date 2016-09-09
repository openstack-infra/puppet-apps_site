#if you want to install app_site without glare support
$vhost_name = $::fqdn
$without_glare = true

class { '::apps_site':
  vhost_name    => $vhost_name,
  without_glare => $without_glare,
}
