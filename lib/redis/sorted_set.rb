class Redis
  #
  # Class representing a sorted set.
  #
  class SortedSet
    require 'enumerator'
    include Enumerable
    require 'redis/helpers/core_commands'
    include Redis::Helpers::CoreCommands
    require 'redis/helpers/serialize'
    include Redis::Helpers::Serialize

    attr_reader :key, :options, :redis
    
    # Create a new Sorted Set.
    def initialize(key, redis=$redis, options={})
      @key = key
      @redis = redis
      @options = options
    end
    
    # Add the specified value to the set only if it does not exist already.
    # Redis: ZADD
    def add(value, score=Time.now.utc.to_f)
      redis.zadd(key, score, to_redis(value))
    end
    
    # Return all values in the sorted set. Redis: ZRANGE(0,-1)
    def values
      from_redis range(0, -1)
    end
    alias_method :get, :values

    # Same functionality as Ruby arrays.  If a single number is given, return
    # just the element at that index using Redis: ZRANGE. Otherwise, return
    # a range of values using Redis: ZRANGE.
    def [](index, length=nil)
      if index.is_a? Range
        range(index.first, index.last)
      elsif length
        range(index, length)
      else
        at(index)
      end
    end
    
    # Return a range of values from +start_index+ to +end_index+.  Can also use
    # the familiar list[start,end] Ruby syntax. Redis: ZRANGE
    def range(start_index, end_index)
      from_redis redis.zrange(key, start_index, end_index)
    end

    # Return the value at the given index. Can also use familiar list[index] syntax.
    # Redis: ZRANGE
    def at(index)
      from_redis redis.zrange(key, index, index)[0]
    end
    
    # Returns true if the specified value is in the set.  Redis: ZSCORE
    def member?(value)
      redis.zscore(key, to_redis(value)) != nil
    end
    alias_method :include?, :member?

    # Delete the value from the set.  Redis: ZREM
    def delete(value)
      redis.zrem(key, value)
    end

    # Iterate through each member of the set.  Redis::Objects mixes in Enumerable,
    # so you can also use familiar methods like +collect+, +detect+, and so forth.
    def each(&block)
      values.each(&block)
    end
    
    # Calculate the intersection and store it in Redis as +name+. Returns the number
    # of elements in the stored intersection. Redis: ZINTER
    def interstore(name, *sets)
      redis.zinter(name, sets.size + 1, key, *keys_from_objects(sets))
    end

    # Calculate the union and store it in Redis as +name+. Returns the number
    # of elements in the stored union. Redis: ZUNION
    def unionstore(name, *sets)
      redis.zunion(name, sets.size + 1, key, *keys_from_objects(sets))
    end

    # The number of members in the sorted set. Aliased as size. Redis: ZCARD
    def length
      redis.zcard(key)
    end
    alias_method :size, :length

    # Returns true if the set has no members. Redis: ZCARD == 0
    def empty?
      length == 0
    end

    def ==(x)
      members == x
    end
    
    def to_s
      members.join(', ')
    end
    
    private
    
    def keys_from_objects(sets)
      raise ArgumentError, "Must pass in one or more set names" if sets.empty?
      sets.collect{|set| set.is_a?(Redis::SortedSet) ? set.key : set}
    end
    
  end
end