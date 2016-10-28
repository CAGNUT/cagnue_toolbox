require 'singleton'

module CagnutToolbox
class Configuration
    include Singleton
    attr_accessor :exe_path

    class << self
      def load config, params
        instance.load config, params
      end
    end

    def load config, params
      @config = config
      attributes.each do |name, value|
        send "#{name}=", value if respond_to? "#{name}="
      end
    end

    def attributes
      {
        exe_path: exe_path
      }
    end

    def exe_path
      CagnutToolbox.root.join('exe')
    end
  end
end
