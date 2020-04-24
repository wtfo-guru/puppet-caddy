require 'spec_helper'
describe 'caddy::config' do
  on_supported_os.each do |os, os_facts|
    svcpro =  case os_facts[:os]['release']['major']
              when '6'
                'redhat'
              else
                'systemd'
              end

    case os_facts[:osfamily]
    when 'Debian'
      caddy_home = '/opt/caddy'
      caddy_user = caddy_group = 'www-data'
    when 'RedHat'
      caddy_home = '/etc/ssl/caddy'
      caddy_user = caddy_group = 'caddy'
    end

    context "on #{os}" do
      context 'with default values' do
        let(:facts) { os_facts.merge(service_provider: svcpro) } # factordb doesn't provide service_provider

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/caddy') }
        it { is_expected.to contain_file('/etc/caddy/Caddyfile') }
        it { is_expected.to contain_file('/etc/caddy/config') }
        it { is_expected.to contain_file("#{caddy_home}/.caddy") }
        it { is_expected.to contain_file('/var/log/caddy') }
        it { is_expected.to contain_user(caddy_user) }
        it { is_expected.to contain_group(caddy_group) }
        it { is_expected.to contain_exec("create #{caddy_home} if needed") }
        it { is_expected.to contain_exec('set cap caddy') }

        if svcpro == 'systemd'
          it { is_expected.to contain_file('/etc/systemd/system/caddy.service') }
          it { is_expected.to contain_file('/etc/systemd/system/caddy.service').that_notifies(['Exec[systemctl-daemon-reload]']) }
          it do
            is_expected.to contain_exec('systemctl-daemon-reload').with(
              refreshonly: 'true',
              path: '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
              command: 'systemctl daemon-reload'
            )
          end
        else
          it { is_expected.to contain_file('/etc/init.d/caddy') }
        end
      end
    end
  end
end
