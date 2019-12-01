require 'rake/testtask'
namespace :test do
  Rake::TestTask.new(fixtures: 'test:prepare') do |t|
    t.pattern = 'test/fixtures/*_test.rb'
  end
end