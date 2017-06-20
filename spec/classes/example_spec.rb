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

          it { is_expected.to contain_apt__source('influxrepo') }

          it { is_expected.to contain_exec('create_telegrafdb') }
          it { is_expected.to contain_exec('wait for grafana') }

          it { is_expected.to contain_grafana_datasource('influxdb') }
          it { is_expected.to contain_grafana_datasource('internal_influxdb') }

          it { is_expected.to contain_grafana_dashboard('Apache Overview') }
          it { is_expected.to contain_grafana_dashboard('HAproxy metrics') }
          it { is_expected.to contain_grafana_dashboard('InfluxDB Metrics') }
          it { is_expected.to contain_grafana_dashboard('MySQL Metrics') }
          it { is_expected.to contain_grafana_dashboard('Telegraf Windows Instances') }
          it { is_expected.to contain_grafana_dashboard('Telegraf system overview') }

        end
      end
    end
  end
end
