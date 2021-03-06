require 'spec_helper_acceptance'

describe 'pip class' do
  context 'global extra index url' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
        class { 'pip':
          package_ensure  => 'latest',
          extra_index_url => 'https://repo.fury.io/yuav/'
        }

        package { 'puppet-pip-test-project':
          provider => 'yuavpip',
          require  => Class['pip'],
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, {
        :catch_failures => true,
        :debug => true,
        :trace => true,
        :environment => {
          # Workaround for bug: https://tickets.puppetlabs.com/browse/BKR-699
          'PATH' => '/opt/puppet-git-repos/hiera/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'
        }
      })
      apply_manifest(pp, {
        :catch_changes => true,
        :debug => true,
        :trace => true,
        :environment => {
          # Workaround for bug: https://tickets.puppetlabs.com/browse/BKR-699
          'PATH' => '/opt/puppet-git-repos/hiera/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'
        }
      })
    end

    describe package('python-pip') do
      it { is_expected.to be_installed }
    end

    # Serverspec test is broken for pip 1.0, since it doesn't have `pip list` command
    #describe package('Django') do
    #  it { should be_installed.by('pip') }
    #end
  end
end
