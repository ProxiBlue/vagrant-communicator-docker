module VagrantPlugins
  module CommunicatorDocker
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :bash_shell

      def initialize
        @bash_shell         = UNSET_VALUE
      end

      def finalize!
        @bash_shell         = '/bin/bash' if @bash_shell == UNSET_VALUE
      end

    end
  end
end
