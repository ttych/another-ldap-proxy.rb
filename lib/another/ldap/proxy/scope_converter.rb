# frozen_string_literal: true

require 'ldap/server'
require 'net/ldap'

module Another
  module Ldap
    module Proxy
      module ScopeConverter
        def self.from_server_to_client(scope)
          case scope
          when LDAP::Server::BaseObject
            Net::LDAP::SearchScope_BaseObject
          when LDAP::Server::SingleLevel
            Net::LDAP::SearchScope_SingleLevel
          when LDAP::Server::WholeSubtree
            Net::LDAP::SearchScope_WholeSubtree
          else
            raise "Unsupported server scope: #{scope}"
          end
        end
      end
    end
  end
end
