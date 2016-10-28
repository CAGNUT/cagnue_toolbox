require "cagnut_toolbox/version"

module CagnutToolbox
  class << self
    def config
      @config ||= begin
        CagnutToolbox::Configuration.load(Cagnut::Configuration.config, Cagnut::Configuration.params['toolbox'])
        CagnutToolbox::Configuration.instance
      end
    end

    def root
      ::Pathname.new File.expand_path '../..', __FILE__
    end
  end
end

require 'cagnut_toolbox/configuration'
require 'cagnut_toolbox/base'
require 'cagnut_toolbox/util'
