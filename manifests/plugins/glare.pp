# == Class: apps_site::plugins::glare
#
class apps_site::plugins::glare (
  $glare_url     = 'http://127.0.0.1:9494/',
  $assets_file   = undef,
  $import_assets = false,
) inherits ::apps_site::params {

  include ::apps_site

  $real_assets_file = $assets_file ? {
    undef   => "${apps_site::params::app_catalog_dir}/web/static/assets.yaml",
    default => $assets_file,
  }

  if $import_assets {
    exec { 'import-glare-assets' :
      command => "app-catalog-import-assets --glare_url ${glare_url} --assets_file ${real_assets_file}",
      path    => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    }
  }

}
