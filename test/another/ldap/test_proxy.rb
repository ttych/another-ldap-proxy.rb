# frozen_string_literal: true

require 'test_helper'

module Another
  module Ldap
    class TestProxy < Minitest::Test
      def test_that_it_has_a_version_number
        refute_nil ::Another::Ldap::Proxy::VERSION
      end
    end
  end
end
