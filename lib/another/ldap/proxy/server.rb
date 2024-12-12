# frozen_string_literal: true

require 'logger'
require 'ldap/server'

module Another
  module Ldap
    module Proxy
      class Server
        SERVER_OPTIONS = %i[port nodelay listen].freeze

        attr_reader :conf

        def initialize(conf:, logger: nil)
          @conf = conf
          @logger = logger
        end

        def server_params
          conf.slice(*SERVER_OPTIONS)
              .update(operation_class_params)
              .update(logger_params)
        end

        def operation_class
          backend_mode = conf[:backend_mode]
          backends_conf = conf[:backends]
          root_username = conf[:root_username]
          root_password = conf[:root_password]
          logger = self.logger
          Another::Ldap::Proxy::Operation.new_operation do
            set_logger(logger)
            set_root_credentials(root_username,
                                 root_password)
            set_backend_mode(backend_mode)
            backends_conf.each do |backend_conf|
              add_backend(Another::Ldap::Proxy::Backend.new_backend(backend_conf, logger: logger))
            end
          end
        end

        def operation_class_params
          { operation_class: operation_class }
        end

        def logger_params
          { logger: logger }
        end

        def run
          @s ||= LDAP::Server.new(
            **server_params
          )

          @s.run_tcpserver
          @s.join
        end

        def logger
          return @logger if @logger

          $stdout.sync = true
          @logger ||= Logger.new($stdout)
          @logger.level = conf.debug ? Logger::DEBUG : Logger::INFO
          @logger
        end

        def self.run(conf:)
          new(conf: conf).run
        end
      end
    end
  end
end
