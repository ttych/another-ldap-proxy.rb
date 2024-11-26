# frozen_string_literal: true

module Another
  module Ldap
    module Proxy
      module EntryConverter
        NORMALIZED_ATTRIBUTE = {
          'objectclass' => 'objectClass',
          'memberof' => 'memberOf'
        }.freeze

        def self.from_client_to_server(entry)
          dn = entry.dn
          attributes = {}

          entry.each do |attribute, value|
            next if attribute.to_s == 'dn'

            attribute = normalize_attribute(attribute)
            attributes[attribute] = value
          end

          [dn, attributes]
        end

        def self.normalize_attribute(attribute)
          attribute = attribute.to_s
          NORMALIZED_ATTRIBUTE.fetch(attribute, attribute)
        end
      end
    end
  end
end
