# Class caddy::params
# ===========================
#
# Default values for caddy module
#
class caddy::params {

  case $::architecture {
    'x86_64', 'amd64': { $arch = 'amd64'}
    'x86'            : { $arch = '386' }
    default:  {
      fail("${facts['os']['architecture']} is not supported.")
    }
  }

  case $facts['os']['family'] {
    'RedHat':  {
      $install_path          = '/usr/local/bin'
      $caddy_home            = '/etc/ssl/caddy'
      $caddy_user            = 'caddy'
      $caddy_group           = 'caddy'
      $caddy_license         = 'personal'
      $caddy_account_id      = undef
      $caddy_api_key         = undef
      $caddy_telemetry       = 'off'
      $caddy_features        = 'http.filter,http.git,http.ipfilter'
      $caddy_log_dir         = '/var/log/caddy'
      $caddy_tmp_dir         = '/tmp'
      $caddy_ssl_dir         = "${caddy_home}/.caddy"
      $caddy_http_port       = 80
      $caddy_https_port      = 443
      $caddy_private_devices = true
      $caddy_limit_processes = 64
    }
    'Debian':  {
      $install_path          = '/usr/local/bin'
      $caddy_home            = '/etc/ssl/caddy'
      $caddy_user            = 'www-data'
      $caddy_group           = 'www-data'
      $caddy_license         = 'personal'
      $caddy_account_id      = undef
      $caddy_api_key         = undef
      $caddy_telemetry       = 'off'
      $caddy_features        = 'http.filter,http.git,http.ipfilter'
      $caddy_log_dir         = '/var/log/caddy'
      $caddy_tmp_dir         = '/tmp'
      $caddy_ssl_dir         = "${caddy_home}/.caddy"
      $caddy_http_port       = 80
      $caddy_https_port      = 443
      $caddy_private_devices = true
      $caddy_limit_processes = 64
      # Ubuntu 18.04 ships with systemd v234, > v229
      $systemd_capabilityboundingset = undef
      $systemd_ambientcapabilities   = undef
      $systemd_nonewprivileges       = undef
    }
    default:  {
      fail("${facts['os']['family']} is not supported.")
    }
  }
}
