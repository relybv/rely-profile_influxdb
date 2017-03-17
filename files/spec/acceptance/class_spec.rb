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
      it 'should work idempotently with no errors' do
        pp = <<-EOS
        class { 'profile_influxdb': }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true, :future_parser => true)
        apply_manifest(pp, :catch_changes  => true, :future_parser => true)
      end
    end


  
# a profile class should test if the included packages and services are installed, enabled and running. Please adept to your needs. See examples below:
#   describe package('ntp') do
#      it { is_expected.to be_installed }
#    end
#
#    describe service('ntp') do
#      it { is_expected.to be_enabled }
#      it { is_expected.to be_running }
#    end
#
#    describe port(5432) do
#      it { should be_listening.with('tcp') }
#    end
  

  end
end
