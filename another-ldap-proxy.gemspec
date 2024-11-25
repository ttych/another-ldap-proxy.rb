# frozen_string_literal: true

require_relative 'lib/another/ldap/proxy/version'

Gem::Specification.new do |spec|
  spec.name = 'another-ldap-proxy'
  spec.version = Another::Ldap::Proxy::VERSION
  spec.authors = ['Thomas Tych']
  spec.email = ['thomas.tych@gmail.com']

  spec.summary = 'Another Ldap Proxy'
  spec.description = 'Another Ldap Proxy implementation for search query.'
  spec.homepage = 'https://gitlab.com/ttych/another-ldap-proxy.rb'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}.git"
  # spec.metadata["changelog_uri"] = ""
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .gitlab-ci.yml appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'gli', '~> 2.22'
  spec.add_dependency 'net-ldap', '~> 0.19.0'
  spec.add_dependency 'ruby-ldapserver', '~> 0.7.0'

  spec.add_development_dependency 'bump', '~> 0.10.0'
  spec.add_development_dependency 'bundler', '~> 2.5.6'
  spec.add_development_dependency 'byebug', '~> 11.1', '>= 11.1.3'
  spec.add_development_dependency 'minitest', '~> 5.16'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'reek', '~> 6.1', '>= 6.1.4'
  spec.add_development_dependency 'rubocop', '~> 1.56'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.36.0'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'
end
