# == Class: apps_site
#
class apps_site (
  $commit                  = 'master',
  $root_dir                = '/opt/apps_site',
  $serveradmin             = "webmaster@${::domain}",
  $ssl_cert_file_contents  = undef,
  $ssl_key_file_contents   = undef,
  $ssl_chain_file_contents = undef,
  $ssl_cert_file           = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $ssl_key_file            = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $ssl_chain_file          = '/etc/ssl/certs/ca-certificates.crt',
  $vhost_name              = $::fqdn,
) {
  include ::httpd::ssl
  include ::httpd::mod::wsgi

  $install_dir = '/usr/local/lib/python2.7/dist-packages/openstack_catalog/'
  $app_catalog_change = 'refs/changes/33/337633/17'

  if !defined(Package['git']) {
    package { 'git':
      ensure => present
    }
  }

  vcsrepo { $root_dir:
    ensure   => latest,
    provider => git,
    revision => $commit,
    source   => 'https://git.openstack.org/openstack/app-catalog.git',
    require  => [
      Package['git'],
    ]
  }

  #Remove this when change will be merged
  exec { "fetch WIP change":
    command     => "git fetch git://git.openstack.org/openstack/app-catalog ${app_catalog_change} && git checkout FETCH_HEAD",
    path        => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    cwd         => $root_dir,
    refreshonly => true,
    subscribe   => Vcsrepo[$root_dir],
  }

  ::httpd::vhost { $vhost_name:
    port       => 443,
    docroot    => "${root_dir}/openstack_catalog/web",
    priority   => '50',
    template   => 'apps_site/vhost.erb',
    vhost_name => $vhost_name,
    ssl        => true,
  }

  httpd_mod { 'headers':
    ensure => present,
    notify => Service['httpd']
  }

  httpd_mod { 'rewrite':
    ensure => present,
    notify => Service['httpd']
  }

  httpd_mod { 'deflate':
    ensure => present,
    notify => Service['httpd']
  }

  if $ssl_cert_file_contents != undef {
    file { $ssl_cert_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_cert_file_contents,
      before  => Httpd::Vhost[$vhost_name],
    }
  }

  if $ssl_key_file_contents != undef {
    file { $ssl_key_file:
      owner   => 'root',
      group   => 'ssl-cert',
      mode    => '0640',
      content => $ssl_key_file_contents,
      before  => Httpd::Vhost[$vhost_name],
    }
  }

  if $ssl_chain_file_contents != undef {
    file { $ssl_chain_file:
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => $ssl_chain_file_contents,
      before  => Httpd::Vhost[$vhost_name],
    }
  }

  if ! defined(Package['python-yaml']) {
    package { 'python-yaml':
      ensure => present,
    }
  }

  if ($::lsbdistcodename == 'trusty') {
    if ! defined(Package['zopfli']) {
      package { 'zopfli':
        ensure => present,
      }
    }
  }

  if ! defined(Package['python-pip']) {
    package { 'python-pip':
      ensure => present,
    }
  }

  # When app-catalog will be delivered as package
  # change exec to package { provider => 'pip'}
  exec { 'install-app_catalog' :
    command     => "pip install --upgrade ${root_dir}",
    path        => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    cwd         => $root_dir,
    refreshonly => true,
    subscribe   => [Vcsrepo[$root_dir], Exec["fetch WIP change"]],
    notify      => Service['httpd'],
  }

  file { "${install_dir}/local_settings.py":
    ensure  => present,
    mode    => '0644',
    require => Exec['install-app_catalog'],
    content => template('apps_site/local_settings.erb'),
  }

  file { "${install_dir}/manage.py":
    ensure  => present,
    source  => "${root_dir}/manage.py",
    require => Exec['install-app_catalog'],
  }

  exec { 'collect-static' :
    command   => "python ${install_dir}/manage.py collectstatic --noinput",
    path      => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
    subscribe => File["${install_dir}/manage.py"],
  }

#  exec { 'python-compress' :
#    command   => "python ${install_dir}/manage.py compress --force",
#    path      => ['/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin'],
#    subscribe => File["${install_dir}/manage.py"],
#  }

  exec { 'make_assets_json' :
    command     => "${root_dir}/tools/update_assets.sh",
    path        => ['/usr/local/bin', '/usr/bin:/bin'],
    refreshonly => true,
    subscribe   => Exec['install-app_catalog'],
  }

}
