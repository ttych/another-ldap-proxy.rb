# frozen_string_literal: true

require_relative 'proxy/version'
require_relative 'proxy/server'
require_relative 'proxy/conf'
require_relative 'proxy/operation'
require_relative 'proxy/backend'

module Another
  module Ldap
    module Proxy
      class Error < StandardError; end
      # Your code goes here...
    end
  end
end
