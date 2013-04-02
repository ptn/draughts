#! /usr/bin/env ruby

require_relative '../../config/bots_test'
require_relative '../../lib/draughts'

include Draughts::AI

bot = TrainingBot.new 'black', 'bbbbbbbb bbbb       wwwwwwwwwwww'
p1 = bot.play
bot.learn(false)
bot = TrainingBot.new 'black', 'bbbbbbbb bbbb       wwwwwwwwwwww'
p2 = bot.play

fail "Bot is not learning" if p1 == p2

puts "Test not_learning passed \\o/"
