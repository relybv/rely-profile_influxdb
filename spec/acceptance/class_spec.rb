if ENV['BEAKER'] == 'true'
  # running in BEAKER test environment
  require 'spec_helper_acceptance'
else
  # running in non BEAKER environment
  require 'serverspec'
  set :backend, :exec
end

describe 'profile_influxdb class' do

  context 'default parameters' do
    if ENV['BEAKER'] == 'true'
      # Using puppet_apply as a helper
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'profile_influxdb': }
        EOS

        apply_manifest(pp, :catch_failures => true)
        # wait because influxdb takes few seconds to start
        shell("/bin/sleep 10")
      end
    end

    describe package('influxdb') do
      it { is_expected.to be_installed }
    end

    describe service('influxdb') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8088) do
      it { should be_listening }
    end

    describe package('grafana') do
      it { is_expected.to be_installed }
    end

    describe service('grafana-server') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(3000) do
      it { should be_listening }
    end

  end
end
