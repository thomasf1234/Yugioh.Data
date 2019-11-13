require 'logger'
require 'active_record'
require 'db/initialize'

Dir[File.join(".", "entities", "**/*.rb")].each do |file|
  require file
end

Dir[File.join(".", "pages", "**/*.rb")].each do |file|
  require file
end

require 'jobs/fetch_cards_job'
require 'jobs/synchronise_database_job'

$logger = Logger.new($stdout)