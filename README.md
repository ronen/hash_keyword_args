# hash_keyword_args

[![Gem Version](https://badge.fury.io/rb/hash_keyword_args.png)](http://badge.fury.io/rb/hash_keyword_args)
[![Build Status](https://secure.travis-ci.org/ronen/hash_keyword_args.png)](http://travis-ci.org/ronen/hash_keyword_args)
[![Dependency Status](https://gemnasium.com/ronen/hash_keyword_args.png)](https://gemnasium.com/ronen/hash_keyword_args)

Defines Hash#keyword_args, which provides convenient features when using a
Hash to provide keyword args to a method:

*   Argument checking
*   Accessor methods for values
*   Default values
*   Required vs. optional arguments
*   Argument value validation


Typical simplest usage is as follows:

    def my_method(args={})
      args = args.keyword_args(:name, :rank)

      puts "name is #{args.name}" if args.name
      puts "rank is #{name.rank}" if args.rank
    end

    my_method()                                    # prints nothing
    my_method(:name => "Kilroy")                   # prints: name is Kilroy
    my_method(:name => "Kilroy", :rank => "Pawn")  # prints: name is Kilroy / rank is Pawn
    my_method(:name => "Kilroy", :serial => 666)   # raises ArgumentError

Notice that you declare the keyword arguments you're willing to accept, and
`keyword_args` returns a new object that has accessors for each argument. If
an non-matching keyword is detected, `keyword_args` raises ArgumentError with
a descriptive message.

For fancier features (such as required arguments, default values, and whatnot)
you specify properties for keywords, as discussed below.

Note another common idiom is to define the keyword args after positional args
("rails style"), e.g.:

    def find(id, opts={})
      opts = opts.keyword_args(:conditions, :order)
      ...
    end
    find(123, :order => :date)

## Details

### Default Values

Normally if a keyword isn't included in the args, the corresponding accessor
will return nil.  But  you can provide default values that will be filled in
if the keyword isn't provided.  E.g.

    def my_method(args={})
      args = args.keyword_args(:name, :rank => "Knight")

      puts "name is #{args.name}" if args.name
      puts "rank is #{name.rank}"
    end

    my_method()                                    # prints: rank is Knight
    my_method(:name => "Kilroy")                   # prints: name is Kilroy / rank is Knight
    my_method(:name => "Kilroy", :rank => "Pawn")  # prints: name is Kilroy / rank is Pawn

Notice that because unadorned hashes must be at the end of ruby calls, any
keywords with default values or other properties need to come after the
ordinary optional keywords.  If you care about the order (or like symmetry in
your code), you can specify the magic symbol :optional instead of a default
value.  So this is equivalent to the above:

    args = args.keyword_args(:rank => "Pawn",
                             :name => :optional)

The above actually show the shortcut form for specifying a default.  There's
also a long form, which can be used in combination with other properties or if
the default value conflicts with a shortcut:

    args = args.keyword_args(:rank => { :default => "Pawn" },
                             :name => { },                       
                             )

### Required Keyword Args

By default, keyword arguments are optional; and if not provided the value is
`nil` or the specified default.  But you can require that an argument be
specified:

    def my_method(args={})
      args = args.keyword_args(:name => :required, :rank => "Pawn")

      puts "name is #{args.name}"
      puts "rank is #{name.rank}"
    end

    my_method()                         # raises ArgumentError with a descriptive message
    my_method(:name => "Kilroy")        # prints: name is Kilroy / rank is Pawn

Again, the above is the shortcut form.  The equivalent long form would be:

    args = args.keyword_args(:name => { :required => true },
                             :rank => { :default => "Pawn"},
                             )

### Value Validation

`keyword_args` can check that the provided values have a given type or are
chosen from among a specified array of values.

    def my_roll(args={})
      args = args.keyword_args(:lucky => Integer,
                               :dice => [:d6, :d10, :d20])

      ...
    end

    my_roll(:lucky => 17, :dice => :d20)    # OK
    my_roll(:lucky => "yes", :dice => :d20) # raises ArgumentError with a descriptive message for :lucky
    my_roll(:lucky => 17, :dice => :d4)     # raises ArgumentError with a descriptive message for :dice
    my_roll(:dice => :d4)                   # raises ArgumentError; :dice is OK but :lucky (nil) isn't an Integer

Note that since the default value, `nil` isn't a valid Integer and wasn't
listed in the collection, the above declaration has implicitly caused those
keywords to be required.  But it's possible to specify default values and/or
allow nil using the long form:

    args = args.keyword_args(:lucky => {:valid => Integer, :allow_nil => true})
    args = args.keyword_args(:lucky => {:valid => Integer, :default => 7})
    args = args.keyword_args(:lucky => {:valid => Integer, :default => 7, :allow_nil => true})

In the third form above, the default value is 7, but if args explicitly
included :lucky => nil it would override the default.

### Enumerable Values

You can specify that you expect a keyword to take an array of values (or other
`Enumerable`), via

    def my_report(args={})
      args = args.keyword_args(:winners => :enumerable)

      args.winners.each do |winner|
        puts "#{winner} is a winner"
      end
    end

    my_report(:winners => ["Bonnie", "Clyde"])  # prints: Bonnie is a winner / Clyde is a winner
    my_report(:winners => "Nero")               # prints: Nero is a winner
    my_report()                                 # prints nothing

Notice that a non-enumerable value gets automatically wrapped in an array for
you, and the default value is an empty array.  If you want to do type checking
on the values, you can use the long form:

    args = args.keyword_args(:winners => { :enumerable => true, :valid => String})

which will perform validity checking on element of the array.  You can combine
:enumerable with a default as well:

    args = args.keyword_args(:winners => { :enumerable => true, :default => ["Huey", "Dewey"] }

### But I like having my options in a Hash!

Not to worry.  The returned object is actually a `Hash` with the accessors
defined in its singleton class, so you can use hash operations on it if
needed. In particular you can pass it in turn to another method.  For example:

    def my_wrapper(args={})
      args = args.keyword_args(:name, :rank, :serial_number)
      @serial_number = args.delete(:serial_number)
      my_method(args)
    end

### Suppress Argument Checking

If you want to suppress argument checking you can specify the magic keyword
`:OTHERS` (with the intended meaning "and other keyword args that aren't
listed here"):

    def execute(operator, opts={})
      opts = opts.keyword_args(:immediately, :OTHERS)
      immediately = opts.delete(:immediately)  # take :immediately out of the list...
      opts.each do |opt, value|                # ...and loop over all the others
        ...
      end
    end

    execute(operator, :yabba => 1, :dabba => 2, :doo => 3)  # not an argument error

No accessor methods are defined for undeclared keywords, but the values will
be available in the hash.  The properties to `:OTHERS` are ignored, but you
can use `:OTHERS => :optional` to make it look nice at the end of a list.

    args = args.keyword_args(:name => String,
                             :OTHERS => :optional)

## Summary

### Complete list of long form properties that can be specified, individually or in combination:

    :key => { :required => boolean }
    :key => { :default => "your default value" }
    :key => { :valid => Class-or-enumeration, :allow_nil => boolean }
    :key => { :enumerable => boolean }  # implies :default => []

### Complete list of shortcuts

    :key => :optional     # short for :key => {}
    :key => :required     # short for :key => {:required => true}
    :key => :enumerable   # short for :key => {:enumerable => true} which in turn implies :default => []
    :key => [1, 2, 3]     # short for :key => {:valid => [1, 2, 3]} validates inclusion in the list
    :key => Class         # short for :key => {:valid => Class}     validates is_a Class
    :key => "whatever"    # anything else is short for :key => {:default => "whatever"}

## Installation

Install via:

    % gem install hash_keyword_args

or in your Gemfile:

    gem "hash_keyword_args

## Versions

Tested on MRI 1.8.7, 1.9.3, and 2.0.0

## History

Past: I've been using this for years and carrying it around from project to
project.  Finally got around to bundling it into a gem.  Maybe somebody other than me
will find this gem useful too.

Future: I hope that this gem will be obviated in future versions of ruby.

## Note on Patches/Pull Requests

*   Fork the project.
*   Make your feature addition or bug fix.
*   Add tests for it.  Make sure that the coverage report (generated
    automatically when you run rspec with ruby >= 1.9) is at 100%
*   Send me a pull request.


## Copyright

Released under the MIT License.  See LICENSE for details.



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/ronen/hash_keyword_args/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

