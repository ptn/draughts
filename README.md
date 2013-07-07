A checkers AI program.

### Current Status

The Engine module is a human-vs-human CLI program. Users input their moves in
[standard notation](http://en.wikipedia.org/wiki/English_draughts#Notation). Run
it with the bin/draughts binary.

The AI module contains a machine learning bot that does Bayes classification to
determine how likely a move is to be legal in the current board - that is, this
bot doesn't play to win, but instead starts the game not knowing the rules of
checkers and has as its objective to eventually play without making mistakes.
It is possible to test the bot directly in an irb-like session (which uses pry)
or to start a game between 2 bots.

### Setup

Simply run `bundle install && rake setup`

### Testing the training bot

Give bin/draughts-console execution permissions (`chmod +x
bin/draughts-console`) and run it.

Once inside the pry session, instantiate a bot with a board configuration:

```ruby
# Board configurations follow checkers' standard notation. There are a few
# samples in examples/configurations.txt
bot = TrainingBot.new("bbbbbbbbbbbb        wwwwwwwwwwww")
```

You can ask him for the probability of a move of your chosing of being legal:

```ruby
move = Move.first(origin: 9, destination: 14)
bot.probability_of(move) # => Float number, like 0.801234532
```

Or ask him to find the most likely move:

```ruby
puts bot.play # => A Move object, which prints as (origin, destination)
```

Once he has chosen his move, teach him whether he was right or wrong:

```ruby
# If the move was legal:
bot.learn(true)
# If it wasn't:
bot.learn(false)
```

This updates the training data so that the bot can make more informed guesses
in the future.

### Starting a game between 2 bots

Give bin/draughts-trainer execution permissions (`chmod +x bin/trainer`) and
run it.  A game (as implemented in the Engine module) between the 2 bots will
start and be narrated to you. Watch them FIGHT TO THE DEATH.

There's a couple of switches you can use:

* If you want to take your time to read what the program is printing, pass the
  `-p` switch. This requires you to type Enter after everything that's printed
before continuing.

* If you want to save the output to review it later, use the `--output=FILE`
  switch.

* If you don't want any output whatsoever, pass the `-q` switch.

### TODO

1. The bot learns embarrasingly slow.
