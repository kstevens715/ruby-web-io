require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['spec/*_spec.rb']
end

task default: :test

desc 'Run an IRB session with ruby_web_io loaded'
task :console do
  require_relative 'lib/ruby_web_io'
  require 'irb'
  require 'irb/completion'

  ARGV.clear
  IRB.start
end
