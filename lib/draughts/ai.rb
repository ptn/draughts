require_relative 'ai/setup'
require_relative 'ai/board'
require_relative 'ai/move'
require_relative 'ai/play'

DataMapper.finalize
DataMapper.auto_upgrade!

require_relative 'ai/training_bot'
