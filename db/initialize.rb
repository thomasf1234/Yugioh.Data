db_name = "Yugioh.sqlite3"
ActiveRecord::Base.logger = Logger.new(File.open("log/#{db_name}.log", 'w+'))

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => File.join('db', db_name),
  :pool => 30
)
