task :resetdb do
  rm 'data/draughts.db', verbose: true
  cp 'data/draughts.db.example', 'data/draughts.db', verbose: true
end

def reset_test_db
  rm 'data/draughts_test.db', verbose: true
  cp 'data/draughts_test.db.example', 'data/draughts_test.db', verbose: true
end

task :resettestdb do
  reset_test_db
end

task :resetall => [:resetdb, :resettestdb] do
end

desc "Run all tests"
task :test do
  Dir['test/integration/*'].each do |test|
    reset_test_db
    puts `ruby #{test}`
  end
end
