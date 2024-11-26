# frozen_string_literal: true

require 'forwardable'
require 'yaml'

module Another
  module Ldap
    module Proxy
      class Conf
        extend Forwardable
        def_delegators :@conf, :slice, :get, :[]

        attr_reader :conf

        def initialize(conf)
          @conf = conf
        end

        def self.from_file(conf_file)
          raise "Configuration file not found: #{conf_file}" unless File.exist?(conf_file)

          conf_data = YAML.safe_load_file(conf_file, symbolize_names: true)
          new(conf_data)
        end
      end
    end
  end
end
