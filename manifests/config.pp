# Class caddy::config
# ===========================
#
# Caddy server setup

class caddy::config inherits caddy {

  group {$caddy::caddy_group:
    ensure => present,
    system => true,
  }

  user {$caddy::caddy_user:
    ensure     => present,
    shell      => '/sbin/nologin',
    gid        => $caddy::caddy_group,
    system     => true,
    home       => $caddy::caddy_home,
    managehome => true,
  }

  # assuming the caddy_user was already installed on the target system
  # the user resource will alter the user's home in /etc/passwd but will
  # not create or initialize it with skel
  exec {"create ${caddy::caddy_home} if needed":
    creates => $caddy::caddy_home,
    command => "mkdir -p '${caddy::caddy_home}'; chmod 755 '${caddy::caddy_home}'; chown ${caddy::caddy_user}:${caddy::caddy_group} '${caddy::caddy_home}'",
    path    => ['/usr/bin', '/bin'],
    before  => File[$caddy::caddy_ssl_dir]
  }

  file {$caddy::caddy_ssl_dir:
    ensure  => directory,
    owner   => $caddy::caddy_user,
    group   => $caddy::caddy_group,
    mode    => '0755',
    require => User[$caddy::caddy_user],
  }

  file {$caddy::caddy_log_dir:
    ensure  => directory,
    owner   => $caddy::caddy_user,
    group   => $caddy::caddy_group,
    mode    => '0755',
    require => User[$caddy::caddy_user],
  }

  file {'/etc/caddy':
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

  file {'/etc/caddy/Caddyfile':
    ensure  => file,
    mode    => '0444',
    owner   => $caddy::caddy_user,
    group   => $caddy::caddy_group,
    source  => 'puppet:///modules/caddy/etc/caddy/Caddyfile',
    require => File['/etc/caddy'],
  }

  file {'/etc/caddy/config':
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0755',
    owner   => $caddy::caddy_user,
    group   => $caddy::caddy_group,
    require => User[$caddy::caddy_user],
  }

  case $facts['service_provider'] {
    'systemd': {
      file {'/etc/systemd/system/caddy.service':
        ensure  => file,
        mode    => '0744',
        owner   => 'root',
        group   => 'root',
        content => template('caddy/etc/systemd/system/caddy.service.erb'),
        notify  => Exec['systemctl-daemon-reload'],
        require => Class['caddy::package'],
      }

      exec {'systemctl-daemon-reload':
        refreshonly => true,
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
        command     => 'systemctl daemon-reload',
        notify      => Service['caddy'],
      }
    }
    default:  {
      file {'/etc/init.d/caddy':
        ensure  => file,
        mode    => '0744',
        owner   => 'root',
        group   => 'root',
        content => template('caddy/etc/init.d/caddy.erb'),
        require => Class['caddy::package'],
        notify  => Service['caddy'],
      }
    }
  }
}
