require 'data_mapper'

module Draughts
  module AI
    base = File.expand_path(Config::DBDIR)
    DataMapper::Logger.new(File.join(base, 'db.log'), :debug)
    DataMapper.setup(:default, 'sqlite://' + File.join(base,'draughts.db'))
  end
end
