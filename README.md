A checkers AI program.

### Current Status

The Engine module is a human-vs-human CLI program. Users input their moves in 
[standard notation](http://en.wikipedia.org/wiki/English_draughts#Notation).

The AI module contains a machine learning bot that does Bayes classification to 
determine how likely a move is to be legal in the current board.

### Testing the training bot

Simply give bin/testbot execution permissions (chmod +x bin/testbot) and run 
it. If you don't already have it, this will copy the sqlite database with 
initial training data to the ~/.draughts dir.

**Known issue:** This prints a bunch of warnings that I haven't figured how to 
quiet yet.

Once inside the irb session, instantiate a bot with a board configuration:

```ruby
# Board configurations follow checkers' standard notation. There are a few 
# samples in examples/configurations.txt
bot = Draughts::AI::TrainingBot.new("bbbbbbbbbbbb        wwwwwwwwwwww")
```

You can ask him for the probability of a move of your chosing of being legal:

```ruby
move = Draughts::AI::Move.first :origin => 9, :destination => 14
bot.probability_of move # => Float number, like 0.801234532
```
 
Or ask him to find the most likely move:

```ruby
puts bot.play # => A Draughts::AI::Move object, which prints as (origin, destination)
```

Once he has chosen his move, teach him whether he was right or wrong:

```ruby
# If the move was legal:
bot.learn true
# If it wasn't:
bot.learn false
```

This updates the training data so that the bot can make more informed guesses 
in the future.
