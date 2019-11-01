require File.expand_path('../lib/communicator-docker/version', __FILE__)

Gem::Specification.new do |s|
  s.name            = 'communicator-docker'
  s.version         = VagrantPlugins::CommunicatorDocker::VERSION
  s.date            = '2019-11-01'
  s.summary         = "Communicate with docker instance"
  s.description     = "Communicate with docker instance"
  s.authors         = ["Lucas van Staden"]
  s.email           = 'sales@proxiblue.com.au'
  s.files           = `git ls-files`.split($\)
  s.executables     = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.require_paths   = ['lib']
  s.homepage        = 'https://www.proxiblue.com.au/'
  s.license         = 'MIT'
end
