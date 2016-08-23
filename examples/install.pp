class {'apps_site':
}
class {'apps_site::wsgi::apache':
  servername => 'catalog.local',
  bind_ip    => '10.109.10.4',
}
class {'apps_site::plugins::glare':
  import_assets => true,
}
