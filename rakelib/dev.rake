require 'irb'

namespace :dev do
  desc "irb session"
  task :irb do
    ARGV.clear
    IRB.start
  end

  desc "hello world"
  task :hello_world do
    puts "hello world!"
  end
end