# frozen_string_literal: true

require_relative 'lib/yabeda/latency/version'

Gem::Specification.new do |spec|
  spec.name          = 'yabeda-latency'
  spec.version       = Yabeda::Latency::VERSION
  spec.authors       = ['Ian Ker-Seymer']
  spec.email         = ['i.kerseymer@gmail.com']

  spec.summary       = 'Collects metrics to monitor latency of HTTP requests'
  spec.description   = 'Extends Yabeda metrics with latency metrics'
  spec.homepage      = 'http://github.com/ianks/yabeda-latency'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'yabeda', '~> 0.2'
end
