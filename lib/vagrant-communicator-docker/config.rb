module VagrantPlugins
  module VagrantCommunicatorDocker
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :bash_shell
      attr_accessor :bash_wait

      def initialize
        @bash_shell         = UNSET_VALUE
        @bash_wait         = UNSET_VALUE
      end

      def finalize!
        @bash_shell         = '/bin/bash' if @bash_shell == UNSET_VALUE
        @bash_wait         = 10 if @bash_wait == UNSET_VALUE
      end

    end
  end
end
