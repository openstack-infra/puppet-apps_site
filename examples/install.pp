class {'apps_site::catalog':
  domain => 'localhost'
}

class {'apps_site::wsgi::apache':
  servername => 'localhost',
  http_port  => 8001,
}

#class {'apps_site::plugins::glare':
#  import_assets => true,
#}
