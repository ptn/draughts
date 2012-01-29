lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'draughts/version'

Gem::Specification.new do |s|
  s.name            = 'draughts'
  s.version         = Draughts::VERSION
  s.summary         = "An AI bot that progressively learns the rules of checkers"
  s.description     = "The bot gathers information and slowly improves to not making incorrect moves"
  s.authors         = ["Pablo Torres"]
  s.email           = 'tn.pablo@gmail.com'
  s.homepage        = 'http://github.com/ptn/draughts'

  s.files           = Dir.glob("{bin,lib}/**/*") + %w(README.md)
  s.executables     = ['draughts', 'trainer', 'testbot'] 
  s.require_path    = 'lib'

  s.add_dependency  "data_mapper"
  s.add_dependency  "pry"
end
