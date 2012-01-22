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

Once inside the irb session, instantiate a bot with the board configuration 
that he has to play and ask him for the most likely move:

```ruby
# Board configurations follow checkers' standard notation. There are a few 
# samples in examples/configurations.txt
bot = Draughts::AI::TrainingBot.new("bbbbbbbbbbbb        wwwwwwwwwwww")
bot.play # => A Draughts::AI::Move object
```

Or ask him for the probability of a move of your chosing of being legal:

```ruby
move = Draughts::AI::Move.first :origin => 9, :destination => 14
bot.probability_of move # => Float number, like 0.801234532
```
