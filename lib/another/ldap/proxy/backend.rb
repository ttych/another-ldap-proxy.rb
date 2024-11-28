# frozen_string_literal: true

require_relative 'backend/ldap'

module Another
  module Ldap
    module Proxy
      module Backend
        class << self
          def new_backend(backend_conf, logger: nil)
            backend_type = backend_conf[:type]
            send("new_backend_#{backend_type}", backend_conf, logger: logger)
          end

          def new_backend_ldap(backend_conf, logger: nil)
            Backend::Ldap.new(**backend_conf, logger: logger)
          end
        end
      end
    end
  end
end
