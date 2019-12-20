class puppetdb (
  # The database url. 5432 is the default port for PostgreSQL
  $db_url = 'localhost:5432'
){
  include '::postgresql'

  # Create a user in PostgreSQL
  postgresql::user { 'puppetdb_user':
    password => 'a_user_pass_',
    before => Service['puppetdb']
  }

  # Create a database in PostgreSQL
  postgresql::user { 'puppetdb':
    owner => 'puppetdb_user',
    before => Service['puppetdb']
  }  

  # Download puppetdb module package if it not already exist
  package { 'puppetdb':
    ensure => 'present',
  }

  # Add the database configuration for puppetdb
  file { 'puppetdb_database.ini':
    ensure => file,
    path => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
    content => epp('puppetdb/database.ini.epp'),
    owner => 'puppet',
    group => 'puppet',
    mode => '0644',
    require => Package['puppetdb'], 
  }

  # Start `puppetdb` service
  service {
    'puppetdb':
      ensure => running,
      enable => true,
      require => Service['postgresql'],
      subscribe => [Package['puppetdb'], File['puppetdb_database.ini']]
  }
}
