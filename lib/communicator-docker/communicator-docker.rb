require 'etc'
require 'logger'
require 'pathname'
require 'stringio'
require 'thread'
require 'timeout'

require 'log4r'
require 'docker'

require 'vagrant/util/ansi_escape_code_remover'
require 'vagrant/util/file_mode'
require 'vagrant/util/keypair'
require 'vagrant/util/platform'
require 'vagrant/util/retryable'

module VagrantPlugins
  module CommunicatorDocker
    # This class provides communication with Docker instances
    class Communicator < Vagrant.plugin("2", :communicator)

      def self.match?(machine)
        # All machines are currently expected to be docker instances.
        return true
      end

      def initialize(machine)
        @lock    = Mutex.new
        @machine = machine
        @logger  = Log4r::Logger.new("vagrant::communication::docker")
        @connection = nil
        @inserted_key = false
      end

      def wait_for_ready(timeout)
        return true
      end

      def ready?
        @logger.debug("Checking whether DOCKER is ready...")
        connect
        @logger.info(Docker.version)
        # If we reached this point then we successfully connected
        return true
      end

      protected

      # Connect to docker API
      def connect(**opts)
          @logger.info("Attempting DOCKER API connection...")
      end
    end
  end
end