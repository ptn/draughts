require 'data_mapper'

module Draughts
  module AI
    base = File.expand_path(Config::DB_DIR)

    if Config::DB_DEBUG
      logfile = File.join(base, 'db.log')
      DataMapper::Logger.new(logfile, :debug)
    end

    DataMapper.setup(:default, 'sqlite://' + File.join(base,'draughts.db'))
  end
end
