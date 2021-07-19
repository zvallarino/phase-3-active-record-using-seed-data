# Using Seed Data

## Learning Goals

- Use a seed file to add sample data to your database
- Use the Faker gem to quickly generate sample data

## Introduction

What good is a database without any data? When working with any application
involving a database, it's a good idea to populate your database with some
realistic data when you are working on building new features. Active Record, and
many other ORMs, refer to the process of adding sample data to the database as
"seeding" the database. In this lesson, we'll see some of the conventions and
built-in features that make it easy to seed data in an Active Record
application.

In this application, we have a migration for one table, `games`:

```rb
# db/migrate/20210718134231_create_games.rb
class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.string :title
      t.string :genre
      t.string :platform
      t.integer :price
      t.timestamps # generates created_at and updated_at columns
    end
  end
end
```

And a corresponding `Game` class that inherits from Active Record:

```rb
# app/models/game
class Game < ActiveRecord::Base

end
```

This lesson is set up as a code-along, so make sure to fork and clone the
lesson. Then run these commands to set up the dependencies and set up the
database:

```sh
bundle install
bundle exec rake db:migrate
```

## Why Do We Need Seed Data?

With Active Record, we've seen how simple it is to add data to a database by
using built-in methods that will write SQL code for us. For instance, to create
a new record in the `games` table, you can open up a console session with
`bundle exec rake console` and use the `.create` method:

```rb
Game.create(title: "Breath of the Wild", platform: "Switch", genre: "Action-adventure", price: 60)
```

Awesome! Our database now has some data in it. We can create a few more games:

```rb
Game.create(title: "Final Fantasy VII", platform: "Playstation", genre: "RPG", price: 60)
Game.create(title: "Mario Kart", platform: "Switch", genre: "Racing", price: 60)
```

Since these records are saved in the database rather than in Ruby's memory, we
know that even after we exit the console, we'll still be able to retrieve this
data.

But how can we share this data with other developers who are working on the same
application? How could we recover this data if our development database was
deleted? We could include the database in version control, but this is generally
considered bad practice: since our database might get quite large over time,
it's not practical to include it in version control (you'll even notice that in
our Active Record projects' `.gitignore` file, we include a line that instructs
Git not to track any `.sqlite3` files). There's got to be a better way!

The common approach to this problem is that instead of sharing the actual
database with other developers, we share the **instructions for creating data in
the database** with other developers. By convention, the way we do this is by
creating a Ruby file, `db/seeds.rb`, which is used to populate our database.

We've already seen a similar scenario by which we can share instructions for
setting up a database with other developers: using Active Record migrations to
define how the database tables should look. Now, we'll have two kinds of database
instructions we can use:

- Migrations: define how our tables should be set up
- Seeds: add data to those tables

## Using the `seeds.rb` File

To use the `seeds.rb` file to add data to the database, all we need to do is
write code that uses Active Record methods to create new records. Add this to
the `db/seeds.rb` file:

```rb
# db/seeds.rb
Game.create(title: "Breath of the Wild", platform: "Switch", genre: "Action-adventure", price: 60)
Game.create(title: "Final Fantasy VII", platform: "Playstation", genre: "RPG", price: 60)
Game.create(title: "Mario Kart", platform: "Switch", genre: "Racing", price: 60)
```

To run this code, you could run `ruby db/seeds.rb`. But since this is a very
common operation, we can also use a Rake task to run the code in this file. Run
the Rake task now:

```sh
bundle exec rake db:seed
```

As long as there aren't any error messages, you won't see any output in the
terminal. We can check if the operation succeeded by entering into the console:

```sh
bundle exec rake console
```

And checking if the records were created:

```rb
Game.count
# => 3
Game.last
# => #<Game:0x00007ff40641f698
#  id: 3,
#  title: "Mario Kart",
#  genre: "Racing",
```

Awesome! Exit out of the console.

What happens if we want to add some more data to the database? Well, we could
try adding another `.create` call in our `db/seeds.rb` file:

```rb
# db/seeds.rb
Game.create(title: "Breath of the Wild", platform: "Switch", genre: "Action-adventure", price: 60)
Game.create(title: "Final Fantasy VII", platform: "Playstation", genre: "RPG", price: 60)
Game.create(title: "Mario Kart", platform: "Switch", genre: "Racing", price: 60)
Game.create(title: "Candy Crush Saga", platform: "Mobile", genre: "Puzzle", price: 0)
```

And running the seed file again, then checking the data in the console:

```sh
bundle exec rake db:seed
bundle exec rake console
```

Let's see our updated data:

```rb
Game.last
# => #<Game:0x00007fc123ae3af8
#  id: 7,
#  title: "Candy Crush Saga",
#  genre: "Puzzle",
#  platform: "Mobile",
Game.count
# => 7
```

Hmm, we only added four games in the `db/seeds.rb` file: why are there now seven
games in the database? Well, remember — every time we run `rake db:seed`, we are
creating **new** records in the `games` table. There's nothing stopping our code
from producing duplicate data in the database. We're just instructing Active
Record to create new code using this file!

We can use another Rake command to [replant][] the seed data:

```sh
bundle exec rake db:seed:replant
```

This command removes the data from all existing tables, and then re-runs the
seed file. It's handy if you want to start fresh! Just be cautious using this
command, since it will delete all your existing data.

We can now see our fresh database with just four records in the `games` table, as
intended. Run `bundle exec rake console`:

```rb
Game.count
# => 4
```

## Generating Randomized Data

One challenge of seeding a database is thinking up lots of sample data.
Ultimately, when you're developing an application, it's helpful to have
realistic data, but the actual content is not so important.

One tool that can be used to help generate a lot of realistic randomized data is
the [Faker gem][faker]. This gem is already included in the Gemfile for this
application, so we can try it out. Run `bundle exec rake console`, and try out
some Faker methods:

```rb
Faker::Name.name
# => "Arnoldo Collier"
Faker::Name.name
# => "Teodoro Thiel"
Faker::Name.name
# => "Monte Stanton"
```

As you can see, every time we call the `#name` method, we get a new random name.
Faker has a lot of [built-in randomized data generators][faker] that you can use:

```rb
Faker::Internet.email
# => "chi@beatty.co"
Faker::Food.ingredient
# => "Jasmine Rice"
Faker::Kpop.girl_groups
# => "2NE1"
```

It even has some for generating game data, which we'll use in our seed file.
Let's use Faker to generate 50 random games. Replace the data in the `seeds.rb`
file with the following code:

```rb
# Add a console message so we can see output when the seed file runs
puts "Seeding games..."

# run a loop 50 times
50.times do
  # create a game with random data
  Game.create(
    title: Faker::Game.title,
    genre: Faker::Game.genre,
    platform: Faker::Game.platform,
    price: rand(0..60) # random number between 0 and 60
  )
end

puts "Done seeding!"
```

Then, run `bundle exec rake db:seed:replant` to re-seed the database. Let's
check out what random games were created with `bundle exec rake console`:

```rb
Game.count
# => 50
Game.last
# => #<Game:0x00007fb4086909d8
#  id: 50,
#  title: "PlayerUnknown's Battlegrounds",
#  genre: "Trivia",
#  platform: "Nintendo 64",
#  price: 16,
#  created_at: 2021-07-18 14:28:56 UTC,
#  updated_at: 2021-07-18 14:28:56 UTC>
```

Great! Now we've got plenty of seed data to work with, and an easy way for
ourselves or other developers to populate the database any time we need to do
so.

Run `learn test` now to pass the test and complete this lesson.

## Conclusion

In this lesson, we learned the importance of having a seed file along with our
database migrations in order for ourselves and other developers to quickly set
up the database with sample data. We also learned how to use the Faker gem
to quickly generate randomized seed data.

## Resources

- [Faker][faker]

[replant]: https://blog.saeloun.com/2019/09/30/rails-6-adds-db-seed-replant-task-and-db-truncate_all.html
[faker]: https://github.com/faker-ruby/faker
