require 'data_mapper'
require_relative '../../../config/bots'

module Draughts
  module AI
    base = File.expand_path(Config::DBDIR)
    DataMapper::Logger.new(File.join(base, 'db.log'), :debug)
    DataMapper.setup(:default, 'sqlite://' + File.join(base,'draughts.db'))
  end
end

require_relative 'board'
require_relative 'move'
require_relative 'play'

DataMapper.finalize
DataMapper.auto_upgrade!
