# frozen_string_literal: true

require "bundler/gem_tasks"
require "rbconfig"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Run the standardrb linter (auto-fix)"
task :lint do
  sh "bundle exec standardrb --fix"
end

desc "Run the hosted Qdrant API end-to-end smoke test"
task :e2e do
  exec RbConfig.ruby, File.expand_path("script/e2e.rb", __dir__)
end

task default: %i[lint spec e2e]
