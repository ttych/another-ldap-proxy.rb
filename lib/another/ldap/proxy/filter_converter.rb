# frozen_string_literal: true

require 'ldap/server'
require 'net/ldap'

module Another
  module Ldap
    module Proxy
      module FilterConverter
        def self.from_server_to_client(filter)
          return filter unless filter.is_a?(Array)

          operator, *items = filter.compact
          case operator
          when :eq
            Net::LDAP::Filter.eq(items.first, items.last)
          when :ge
            Net::LDAP::Filter.ge(items.first, items.last)
          when :le
            Net::LDAP::Filter.le(items.first, items.last)
          when :present
            Net::LDAP::Filter.pres(items.first)
          when :and
            Net::LDAP::Filter.join(from_server_to_client(items.first),
                                   from_server_to_client(items.last))
          when :or
            Net::LDAP::Filter.intersect(from_server_to_client(items.first),
                                        from_server_to_client(items.last))
          when :not
            Net::LDAP::Filter.negate(from_server_to_client(items.first))
          else
            raise "Unsupported server filter operator: #{operator}"
          end
        end
      end
    end
  end
end
