# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/test_*.rb']
end

Rake::RDocTask.new do |rd|
  rd.main = 'README.md'
  rd.markup = 'markdown'
  rd.rdoc_files.include('README.md', 'lib/**/*.rb')
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[test rubocop]
task format: %i[rubocop:auto_correct]
