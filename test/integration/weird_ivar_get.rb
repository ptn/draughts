#! /usr/bin/env ruby

# these were the exact steps to reproduce the bug in the console, but I
# couldn't reproduce them with a test :/ also, using config/bots_test.rb gives
# the wrong id for real_board. This is weird.
require_relative '../../config/bots'
require_relative '../../lib/draughts'

include Draughts::AI

bot = TrainingBot.new('black', 'bbbbbbbbbb b  b w    wwwwwwwwwww')
bot.play
real_board = bot.instance_variable_get("@real_board")
real_board.plays
bot.learn(false)

fail "Bot is not learning" if real_board.plays.empty?

puts "Test weird_ivar_get passed \\o/"
