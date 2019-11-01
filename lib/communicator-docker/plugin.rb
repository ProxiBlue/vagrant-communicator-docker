begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant AWS plugin must be run within Vagrant."
end

module VagrantPlugins
  module communicatorDocker
    class Plugin < Vagrant.plugin("2")
      name "Docker Communicator"
      description <<-DESC
      This plugin allows Vagrant to communicate with docker instances that do not have SSH,
      but can use docker exec to run commands within
      DESC

      communicator("docker") do
        require File.expand_path("../communicator-docker", __FILE__)
        Communicator
      end
    end
  end
end