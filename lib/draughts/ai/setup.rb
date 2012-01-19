require 'data_mapper'

module Draughts
  module Bot
    base = File.expand_path("~/.draughts")
    DataMapper::Logger.new(File.join(base, 'db.log'), :debug)
    DataMapper.setup(:default, 'sqlite://' + File.join(base,'draughts.db'))
  end
end

require_relative 'board'
require_relative 'move'
require_relative 'play'
require_relative '../../../config/bots'

DataMapper.finalize
DataMapper.auto_upgrade!
