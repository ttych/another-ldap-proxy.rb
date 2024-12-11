# frozen_string_literal: true

require 'uri'
require 'net/ldap'

module Another
  module Ldap
    module Proxy
      module Backend
        class Ldap
          TYPE = 'ldap'
          CONNECT_TIMEOUT = 15

          attr_reader :url, :base, :auth_method, :username, :password, :type,
                      :ca_file, :logger, :parsed_url

          def initialize(url:, base:, auth_method:, username:, password:, type:, ca_file: nil, logger: nil,
                         **unused)
            @url = url
            @base = base
            @auth_method = auth_method
            @username = username
            @password = password
            @type = type
            @ca_file = ca_file
            @logger = logger
            @unused = unused

            @parsed_url = URI.parse(url)

            raise "backend type is expected to be #{TYPE} not '#{type}'" unless type == TYPE
          end

          def new_client(host: self.host, port: self.port, base: self.base, auth: self.auth,
                         encryption: self.encryption, connect_timeout: CONNECT_TIMEOUT)
            Net::LDAP.new(
              host: host,
              port: port,
              base: base,
              auth: auth,
              encryption: encryption,
              connect_timeout: connect_timeout
            )
          end

          def client
            @client ||= new_client
          end

          def host
            parsed_url.host
          end

          def port
            parsed_url.port
          end

          def auth(username: self.username, password: self.password)
            return unless auth_method && username && password

            { method: auth_method.to_sym,
              username: username,
              password: password }
          end

          def encryption
            return unless parsed_url.scheme == 'ldaps'

            { method: :simple_tls,
              tls_options: { ca_file: ca_file } }
          end

          def bind(_version, dn, password)
            logger&.info "Ldap#bind : dn:#{dn}"
            logger&.debug "Ldap#bind : dn:#{dn} password:#{password}"
            bind_ldap = new_client(auth: auth(username: dn, password: password))
            status = bind_ldap.bind ? true : false
            logger&.info "Ldap#bind : #{dn} => #{status}"

            status
          end

          def search(basedn, scope, _deref, filter)
            logger&.debug "Ldap#search : filter:#{filter}"
            results = []
            client.search(base: search_base(basedn), scope: scope, filter: filter, return_results: true) do |entry|
              results << entry
            end
            logger&.info "Ldap#search : results => #{results.size}"
            results
          rescue Net::LDAP::Error => e
            logger&.warn "Ldap#search : Error querying LDAP server: #{e.message}"
            []
          end

          def search_base(basedn)
            return base unless basedn
            return basedn if basedn.include?(base)

            base
          end
        end
      end
    end
  end
end
