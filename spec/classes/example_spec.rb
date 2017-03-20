require 'spec_helper'

describe 'profile_influxdb' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge({
            :concat_basedir => "/foo"
          })
        end

        context "profile_influxdb class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('profile_influxdb') }
          it { is_expected.to contain_class('profile_influxdb::install') }
          it { is_expected.to contain_class('profile_influxdb::config') }
          it { is_expected.to contain_class('profile_influxdb::service') }
          it { is_expected.to contain_class('influxdb') }
          it { is_expected.to contain_class('grafana') }

        end
      end
    end
  end
end
