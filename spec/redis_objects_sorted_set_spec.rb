require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'redis/sorted_set'
require 'redis/set'

describe Redis::Set do
  before :all do
    @sorted_set = Redis::SortedSet.new('spec/sorted_set')
    @sorted_set_1 = Redis::SortedSet.new('spec/sorted_set_1')
    @sorted_set_2 = Redis::SortedSet.new('spec/sorted_set_2')
    @sorted_set_3 = Redis::SortedSet.new('spec/sorted_set_3')
  end

  before :each do
    @sorted_set.clear
    @sorted_set_1.clear
    @sorted_set_2.clear
    @sorted_set_3.clear
  end

  it "should handle sets of simple values" do
    @sorted_set.should be_empty
    @sorted_set << 'a' << 'a' << 'a'
    @sorted_set.should == ['a']
    @sorted_set.get.should == ['a']
    @sorted_set << 'b' << 'b'
    @sorted_set.to_s.should == 'a, b'
    @sorted_set.should == ['a','b']
    @sorted_set.members.should == ['a','b']
    @sorted_set.get.should == ['a','b']
    @sorted_set << 'c'
    @sorted_set.sort.should == ['a','b','c']
    @sorted_set.get.sort.should == ['a','b','c']
    @sorted_set.delete('c')
    @sorted_set.should == ['a','b']
    @sorted_set.get.sort.should == ['a','b']
    @sorted_set.length.should == 2
    @sorted_set.size.should == 2
    
    i = 0
    @sorted_set.each do |st|
      i += 1
    end
    i.should == @sorted_set.length

    coll = @sorted_set.collect{|st| st}
    coll.should == ['a','b']
    @sorted_set.should == ['a','b']
    @sorted_set.get.should == ['a','b']

    @sorted_set << 'c'
    @sorted_set.member?('c').should be_true
    @sorted_set.include?('c').should be_true
    @sorted_set.member?('no').should be_false
    coll = @sorted_set.select{|st| st == 'c'}
    coll.should == ['c']
    @sorted_set.sort.should == ['a','b','c']
  end
  
  it "should handle set intersections, unions" do
    @sorted_set_1 << 'a' << 'b' << 'c' << 'd' << 'e'
    @sorted_set_2 << 'c' << 'd' << 'e' << 'f' << 'g'
    @sorted_set_3 << 'a' << 'd' << 'g' << 'l' << 'm'
    @sorted_set_1.sort.should == %w(a b c d e)
    @sorted_set_2.sort.should == %w(c d e f g)
    @sorted_set_3.sort.should == %w(a d g l m)
    @sorted_set_1.interstore(INTERSTORE_KEY, @sorted_set_2).should == 3
    @sorted_set_1.redis.zrange(INTERSTORE_KEY, 0, -1).sort.should == ['c','d','e']
    @sorted_set_1.interstore(INTERSTORE_KEY, @sorted_set_2, @sorted_set_3).should == 1
    @sorted_set_1.redis.zrange(INTERSTORE_KEY, 0, -1).sort.should == ['d']
    @sorted_set_1.unionstore(UNIONSTORE_KEY, @sorted_set_2).should == 7
    @sorted_set_1.redis.zrange(UNIONSTORE_KEY, 0, -1).sort.should == ['a','b','c','d','e','f','g']
    @sorted_set_1.unionstore(UNIONSTORE_KEY, @sorted_set_2, @sorted_set_3).should == 9
    @sorted_set_1.redis.zrange(UNIONSTORE_KEY, 0, -1).sort.should == ['a','b','c','d','e','f','g','l','m']
  end

  it "should support renaming sets" do
    @sorted_set.should be_empty
    @sorted_set << 'a' << 'b' << 'a' << 3
    @sorted_set.sort.should == ['3','a','b']
    @sorted_set.key.should == 'spec/sorted_set'
    @sorted_set.rename('spec/sorted_set2').should be_true
    @sorted_set.key.should == 'spec/sorted_set2'
    old = Redis::SortedSet.new('spec/sorted_set')
    old.should be_empty
    old << 'Tuff'
    @sorted_set.renamenx('spec/sorted_set').should be_false
    @sorted_set.renamenx(old).should be_false
    @sorted_set.renamenx('spec/foo').should be_true
    @sorted_set.clear
    @sorted_set.redis.del('spec/sorted_set2')
  end

  after :all do
    @sorted_set.clear
    @sorted_set_1.clear
    @sorted_set_2.clear
    @sorted_set_3.clear
  end
end
