# frozen_string_literal: true

require_relative "lib/qdrant/version"

Gem::Specification.new do |spec|
  spec.name = "qdrant-ruby"
  spec.version = Qdrant::VERSION
  spec.authors = ["Andrei Bondarev"]
  spec.email = ["andrei@sourcelabs.io", "andrei.bondarev13@gmail.com"]

  spec.summary = "Ruby wrapper for the Qdrant vector search database API"
  spec.description = "Ruby wrapper for the Qdrant vector search database API"
  spec.homepage = "https://github.com/andreibondarev/qdrant-ruby"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/andreibondarev/qdrant-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/andreibondarev/qdrant-ruby/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency "faraday", "~> 1"
  spec.add_development_dependency "pry-byebug", "~> 3.9"
end
