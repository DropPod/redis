class redis {
  package { 'redis': ensure => installed, provider => 'homebrew' }

  $LaunchAgents = "/Users/${id}/Library/LaunchAgents"
  unless defined(File[$LaunchAgents]) {
    file { "${LaunchAgents}":
      ensure => directory,
      mode   => '0755',
    }
  }

  $plist = "${LaunchAgents}/homebrew.redis.plist"
  file { "${plist}":
    ensure  => link,
    target  => '/usr/local/opt/redis/homebrew.mxcl.redis.plist',
    require => [Package['redis']],
    before  => [Exec['Starting Redis']],
  }

  $redis_is_running = "/usr/local/bin/redis-cli ping"

  exec { "Starting Redis":
    command => "/bin/launchctl load ${plist}",
    unless  => $redis_is_running,
    require => [Package['redis']],
  }

  exec { "Waiting for Redis":
    command   => $redis_is_running,
    unless    => $redis_is_running,
    tries     => 30,
    try_sleep => 1,
    require   => [Exec['Starting Redis']],
  }
}
