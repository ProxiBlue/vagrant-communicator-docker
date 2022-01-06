require 'logger'
require 'timeout'
require 'rubygems/package'
require 'fileutils'

require 'log4r'
require 'docker'

module VagrantPlugins
  module VagrantCommunicatorDocker
    # This class provides communication with Docker instances
    class Communicator < Vagrant.plugin("2", :communicator)

      def self.match?(machine)
        # All machines are currently expected to be docker instances.
        return true
      end

      def initialize(machine)
        @logger  = Log4r::Logger.new("vagrant::communication::docker")
        @machine = machine
        @machineID = machine.id
        @logger.debug("MACHINE ID #{@machineID}")
        @logger.debug("MACHINE SHELL: #{@machine.config.communicator.bash_shell}")
        @logger.debug("SHELL WAIT: #{@machine.config.communicator.bash_wait}")
      end

      def ready?
        begin
            @logger.info(Docker.version)
            @container = Docker::Container.get(@machineID)
            @logger.debug(@container.json)
            # If we reached this point then we successfully connected
            @logger.debug("DOCKER COMMUNICATOR connected to #{@machineID}")
            true
        rescue
            @logger.debug("DOCKER COMMUNICATOR - Could not make connection to #{@machineID}")
            false
        end
      end

      # wait_for_ready waits until the communicator is ready, blocking
      # until then. It will wait up to the given duration or raise an
      # exception if something goes wrong.
      #
      # @param [Integer] duration Timeout in seconds.
      # @return [Boolean] Will return true on successful connection
      #   or false on timeout.
      def wait_for_ready(duration)
        # By default, we implement a naive solution.
        begin
          Timeout.timeout(duration) do
            while true
              return true if ready?
              sleep 0.5
            end
          end
        rescue Timeout::Error
          # We timed out, we failed.
          @logger.debug("DOCKER COMMUNICATOR - Timeout to ready")
        end

        return false
      end

      # Download a file from the remote machine to the local machine.
      #
      # @param [String] from Path of the file on the remote machine.
      # @param [String] to Path of where to save the file locally.
      def download(from, to)
        @logger.debug("DOCKER COMMUNICATOR - DOWNLOAD from: #{from} to: #{to}")
        tempfile = "/tmp/#{SecureRandom.urlsafe_base64}.tar"
        @logger.debug("DOCKER COMMUNICATOR - tempfile - #{tempfile}")
        File.open(tempfile, "w") do |file|
            @container.archive_out(from) do |chunk|
                file.write(chunk)
            end
        end
        Gem::Package::TarReader.new( File.open(tempfile) ) do |tar|
            tar.each do |entry|
                File.open to, "wb" do |f|
                    f.print entry.read
                end
            end
        end
      end

      # Upload a file to the remote machine.
      #
      # @param [String] from Path of the file locally to upload.
      # @param [String] to Path of where to save the file on the remote
      #   machine.
      def upload(from, to)
        to_folder = File.dirname(to)
        from_filename = File.basename(from)
        @logger.debug("DOCKER COMMUNICATOR - upload from: #{from} to: #{to_folder} from_filename: #{from_filename}")
        @container.archive_in(from, File.dirname(to), overwrite: true)
        execute("mv #{to_folder}/#{from_filename} #{to}")
      end

      # Execute a command on the remote machine. The exact semantics
      # of this method are up to the implementor, but in general the
      # users of this class will expect this to be a shell.
      #
      # This method gives you no way to write data back to the remote
      # machine, so only execute commands that don't expect input.
      #
      # @param [String] command Command to execute.
      # @yield [type, data] Realtime output of the command being executed.
      # @yieldparam [String] type Type of the output. This can be
      #   `:stdout`, `:stderr`, etc. The exact types are up to the
      #   implementor.
      # @yieldparam [String] data Data for the given output.
      # @return [Integer] Exit code of the command.
      def execute(command, opts=nil)
        begin
            @logger.debug("DOCKER COMMUNICATOR - EXECUTE: #{command}")
            wait_for_ready(@machine.config.communicator.bash_wait)
            @logger.debug("DOCKER COMMUNICATOR - Ready to EXECUTE")
            result = @container.exec([@machine.config.communicator.bash_shell, '-c' , command], tty: true)
            @logger.debug(result)
            if result.first.length > 0
                result.first.first.each_line do |line|
                    yield :stdout, line if block_given?
                end
            end
            return result.last
        rescue => e
            @logger.info("DOCKER COMMUNICATOR: Error running command " + command + " on guest using shell #{@machine.config.communicator.bash_shell}")
            @logger.error ([e.message]+e.backtrace).join($/)
        end
        return 255
      end

      # Executes a command on the remote machine with administrative
      # privileges. See {#execute} for documentation, as the API is the
      # same.
      #
      # @see #execute
      def sudo(command, opts=nil)
        @logger.debug("DOCKER COMMUNICATOR - EXECUTE WITH SUDO: #{command}")
        execute(command, opts)
      end

      # Executes a command and returns true if the command succeeded,
      # and false otherwise. By default, this executes as a normal user,
      # and it is up to the communicator implementation if they expose an
      # option for running tests as an administrator.
      #
      # @see #execute
      def test(command, opts=nil)
        result = execute(command)
        if result == 0
            return true
        end
        return false
      end

       # Reset the communicator. For communicators which establish
      # a persistent connection to the remote machine, this connection
      # should be terminated and re-established. The communicator
      # instance should be in a "fresh" state after calling this method.
      def reset!
         @logger.debug("DOCKER COMMUNICATOR - RESET - NOT IMPLEMENTED")
      end

    end
  end
end