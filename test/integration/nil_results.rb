#! /usr/bin/env ruby

require_relative '../../config/bots_test'
require_relative '../../lib/draughts'

game = Draughts::Engine::Game.new
result = game.play(10, 1)
fail "Game returns a result without `success` set" if result.success.nil?

bot = Draughts::AI::TrainingBot.new 'black', 'bbbbbbbbbbbb        wwwwwwwwwwww'
result = bot.play
fail "Bots return nil instead of playing at random" if result.nil?

puts "Test nil_results passed! \\o/"
