# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'bbhmm'
  spec.version       = '0.0.1'
  spec.required_ruby_version = '>= 2.5'
  spec.authors       = ['Jônatas Davi Paganini', 'Henrich Moraes']
  spec.email         = ['jonatasdp@gmail.com']

  spec.summary       = 'Simplify house expenses'
  spec.description   = 'Allow you share house expenses and simplify the payments between the members.'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = %w[lib]

  spec.add_dependency 'telegram-bot-ruby'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-livereload'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
end
