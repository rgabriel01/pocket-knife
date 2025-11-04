# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# RSpec task
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = ['--format documentation', '--color']
end

# RuboCop task
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

# Combined test task (runs both RSpec and RuboCop)
desc 'Run all tests and linting'
task test: %i[spec rubocop]

# Install task
desc 'Install pocket-knife to /usr/local/bin'
task :install do
  bin_file = File.expand_path('bin/pocket-knife', __dir__)
  install_path = '/usr/local/bin/pocket-knife'

  abort 'Error: bin/pocket-knife not found. Run implementation first.' unless File.exist?(bin_file)

  # Copy binary to /usr/local/bin
  sh "cp #{bin_file} #{install_path}"
  sh "chmod +x #{install_path}"

  puts "✅ pocket-knife installed to #{install_path}"
  puts "Run 'pocket-knife --help' to get started"
end

# Uninstall task
desc 'Uninstall pocket-knife from /usr/local/bin'
task :uninstall do
  install_path = '/usr/local/bin/pocket-knife'

  if File.exist?(install_path)
    sh "rm #{install_path}"
    puts "✅ pocket-knife uninstalled from #{install_path}"
  else
    puts "pocket-knife is not installed at #{install_path}"
  end
end

# Default task
task default: :test
