require "vagrant"

module VagrantPlugins
  module communicatorDocker
    class Plugin < Vagrant.plugin("2")
      name "docker communicator"
      description <<-DESC
      This plugin allows Vagrant to communicate with docker instances that do not have SSH,
      but can use docker exec to run commands within
      DESC

      communicator("docker") do
        require File.expand_path("../docker", __FILE__)
        Communicator
      end
    end
  end
end