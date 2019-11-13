namespace :jobs do
  desc "fetch cards as json"
  task :fetch do
    YugiohData::Jobs::FetchCardsJob.new.perform
  end

  desc "synchronise cards as json"
  task :synchronise do
    YugiohData::Jobs::SynchroniseDatabaseJob.new.perform
  end
end