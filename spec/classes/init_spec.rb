require 'spec_helper'

describe 'caddy' do
  on_supported_os.each do |os, facts|
    service_provider =  case facts[:os]['release']['major']
                        when '6'
                          'redhat'
                        else
                          'systemd'
                        end
    # service_provider it provided by stdlib, not facterdb
    os_facts = facts.merge(service_provider: service_provider)

    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'with defaults for all parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('caddy') }
        it { is_expected.to contain_class('caddy::package').that_comes_before('Class[caddy::config]') }
        it { is_expected.to contain_class('caddy::config').that_notifies('Class[caddy::service]') }
        it { is_expected.to contain_class('caddy::service') }
        it do
          is_expected.to contain_group('caddy').with(
            'ensure' => 'present',
            'system' => 'true'
          )
        end
        it do
          is_expected.to contain_user('caddy').with(
            'ensure'     => 'present',
            'shell'      => '/sbin/nologin',
            'gid'        => 'caddy',
            'system'     => 'true',
            'home'       => '/etc/ssl/caddy',
            'managehome' => 'true'
          )
        end

        it do
          is_expected.to contain_exec('install caddy').with(
            'command' => 'curl -o /tmp/caddy_linux_amd64_custom.tar.gz \'https://caddyserver.com/download/linux/amd64?plugins=http.filter,http.git,http.ipfilter&license=personal&telemetry=off\'',
            'creates' => '/usr/local/bin/caddy'
          )
        end
        it do
          is_expected.to contain_exec('extract caddy').with(
            'command' => 'tar -zxf /tmp/caddy_linux_amd64_custom.tar.gz -C /usr/local/bin \'caddy\'',
            'creates' => '/usr/local/bin/caddy',
            'require' => 'Exec[install caddy]'
          )
        end
        it do
          is_expected.to contain_file('/usr/local/bin/caddy').with(
            'mode'    => '0755',
            'owner'   => 'root',
            'group'   => 'root',
            'notify'  => 'Exec[set cap caddy]',
            'require' => 'Exec[extract caddy]'
          )
        end
        it do
          is_expected.to contain_exec('set cap caddy').with(
            'command'     => 'setcap cap_net_bind_service=+ep /usr/local/bin/caddy',
            'require'     => 'File[/usr/local/bin/caddy]',
            'refreshonly' => 'true'
          )
        end

        it do
          is_expected.to contain_file('/etc/ssl/caddy/.caddy').with(
            'ensure'  => 'directory',
            'owner'   => 'caddy',
            'group'   => 'caddy',
            'mode'    => '0755'
          )
        end
        it do
          is_expected.to contain_file('/var/log/caddy').with(
            'ensure'  => 'directory',
            'owner'   => 'caddy',
            'group'   => 'caddy',
            'mode'    => '0755'
          )
        end
        it do
          is_expected.to contain_file('/etc/caddy').with(
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755'
          )
        end
        it do
          is_expected.to contain_file('/etc/caddy/Caddyfile').with(
            'ensure'  => 'file',
            'owner'   => 'caddy',
            'group'   => 'caddy',
            'mode'    => '0444',
            'source'  => 'puppet:///modules/caddy/etc/caddy/Caddyfile',
            'require' => 'File[/etc/caddy]'
          )
        end
        it do
          is_expected.to contain_file('/etc/caddy/config').with(
            'ensure'  => 'directory',
            'purge'   => 'true',
            'recurse' => 'true',
            'owner'   => 'caddy',
            'group'   => 'caddy',
            'mode'    => '0755'
          )
        end

        case os_facts[:service_provider]
        when 'systemd'
          it do
            is_expected.to contain_systemd__unit_file('caddy.service').with(
              'content' => %r{User=caddy}
            )
          end
        when 'redhat'
          it do
            is_expected.to contain_file('/etc/init.d/caddy').with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0744',
              'content' => %r{DAEMONUSER=caddy}
            )
          end
        end
        it do
          is_expected.to contain_service('caddy').with(
            'ensure' => 'running',
            'enable' => 'true'
          )
        end
      end
    end
  end
end
