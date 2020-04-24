require 'spec_helper'
describe 'caddy::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      context 'with default values' do
        let(:facts) { os_facts }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('caddy') }
        it { is_expected.to contain_service('caddy') }
      end
    end
  end
end
