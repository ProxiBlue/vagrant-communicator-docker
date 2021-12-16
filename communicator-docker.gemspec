require File.expand_path('../lib/vagrant-communicator-docker/version', __FILE__)

Gem::Specification.new do |s|
  s.name            = 'vagrant-communicator-docker'
  s.version         = VagrantPlugins::VagrantCommunicatorDocker::VERSION
  s.date            = '2019-11-01'
  s.summary         = "Simulate SSH using Docket API when provisioning vagrant machines that use docker images without SSH"
  s.description     = "Simulate SSH using Docket API when provisioning vagrant machines that use docker images without SSH"
  s.authors         = ["Lucas van Staden"]
  s.email           = 'sales@proxiblue.com.au'
  s.files           = `git ls-files`.split($\)
  s.executables     = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.require_paths   = ['lib']
  s.homepage        = 'https://github.com/ProxiBlue/vagrant-communicator-docker'
  s.license         = 'MIT'
  s.add_dependency 'docker-api', '>= 2.0.0'
end
