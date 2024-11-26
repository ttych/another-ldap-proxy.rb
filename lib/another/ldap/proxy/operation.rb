# frozen_string_literal: true

require 'logger'
require 'ldap/server'

require_relative 'scope_converter'
require_relative 'filter_converter'
require_relative 'entry_converter'

module Another
  module Ldap
    module Proxy
      class Operation < LDAP::Server::Operation
        PROXY_MODE_FIRST = 'first'

        attr_reader :logger

        def initialize(connection, messageID)
          super

          @proxy_mode = self.class.backend_mode
          @proxy_backends = self.class.backends
          @root_username = self.class.root_username
          @root_password = self.class.root_password
          @logger = self.class.logger
        end

        def simple_bind(version, dn, password)
          logger&.info "Operation#simple_bind ( #{version}, #{dn}, *** )"

          return if _validate_root_credentials(dn, password)

          @proxy_backends.each do |backend|
            return if backend.bind(version, dn, password)
          end

          logger&.warn "Operation#simple_bind : user #{dn} rejected"
          raise LDAP::ResultError::InvalidCredentials, "user #{dn} rejected"
        end

        def search(basedn, scope, deref, filter)
          logger&.info "Operation#search ( #{basedn}, #{scope}, #{filter} )"

          client_scope = Another::Ldap::Proxy::ScopeConverter.from_server_to_client(scope)
          client_filter = Another::Ldap::Proxy::FilterConverter.from_server_to_client(filter)

          @proxy_backends.each do |backend|
            results = backend.search(basedn, client_scope, deref, client_filter)

            next if results.empty?

            results.each do |entry|
              dn, attributes = Another::Ldap::Proxy::EntryConverter.from_client_to_server(entry)
              send_SearchResultEntry(dn, attributes)
            end

            break if @proxy_mode == PROXY_MODE_FIRST
          end
        end

        def _validate_root_credentials(username, password)
          @root_username == username && @root_password == password
        end

        class << self
          attr_reader :backend_mode, :backends, :root_username, :root_password, :logger

          def new_operation(&block)
            proxy_operation_class = Class.new(self)
            proxy_operation_class.instance_eval(&block) if block_given?
            proxy_operation_class
          end

          def set_logger(logger)
            @logger = logger
          end

          def set_root_credentials(root_username, root_password)
            @root_username = root_username
            @root_password = root_password
          end

          def set_backend_mode(backend_mode)
            @backend_mode = backend_mode
          end

          def add_backend(backend)
            @backends ||= []
            @backends << backend if backend
          end
        end
      end
    end
  end
end
