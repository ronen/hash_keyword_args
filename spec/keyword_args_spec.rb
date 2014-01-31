require 'spec_helper'

describe "keyword_args" do

  it "unadorned args should be optional" do
    expect { @args = {:a => 17}.keyword_args(:a, :b) }.to_not raise_error
    @args.a.should == 17
    @args.b.should be_nil
  end

  it ":optional args should be optional" do
    expect { @args = {:a => 17}.keyword_args(:a => :optional, :b => :optional) }.to_not raise_error
    @args.a.should == 17
    @args.b.should be_nil
  end

  it ":required args should be required" do
    expect { @args = {:a => 17}.keyword_args(:a => :required, :b => :required) }.to raise_error(ArgumentError)
    expect { @args = {:a => 17, :b => 32}.keyword_args(:a => :required, :b => :required) }.to_not raise_error
    @args.a.should == 17
    @args.b.should == 32
  end

  it "should handle default value" do
    @args = {:a => "alpha"}.keyword_args(:a => "adam", :b => "baker")
    @args.a.should == "alpha"
    @args.b.should == "baker"
  end

  it "should complain about invalid args" do
    expect { @args = {:a => "whatever"}.keyword_args(:b) }.to raise_error(ArgumentError)
  end

  it "should not complain about invalid args if :OTHERS is given" do
    expect { @args = {:a => "whatever"}.keyword_args(:b) }.to raise_error(ArgumentError)
    expect { @args = {:a => "whatever"}.keyword_args(:b, :OTHERS) }.to_not raise_error
    @args[:a].should == "whatever"
  end

  it "should not define method for OTHERS arg" do
    @args = {:a => "whatever"}.keyword_args(:b, :OTHERS)
    expect { @args.a }.to raise_error(NoMethodError)
    @args[:a].should == "whatever"
  end

  it "should validate against list of values" do
    expect { @args = {:a => :BAD}.keyword_args(:a => [:OK, :GOOD]) }.to raise_error(ArgumentError)
    expect { @args = {:a => :OK}.keyword_args(:a => [:OK, :GOOD]) }.to_not raise_error
    @args.a.should == :OK
  end

  it "should validate against class" do
    expect { @args = {:a => "hello"}.keyword_args(:a => Integer) }.to raise_error(ArgumentError)
    expect { @args = {:a => 17}.keyword_args(:a => Integer) }.to_not raise_error
    @args.a.should == 17
  end

  it "should allow validity set via hash" do
    expect { @args = {:a => "hello"}.keyword_args(:a => {:valid => Integer}) }.to raise_error(ArgumentError)
    expect { @args = {:a => 17}.keyword_args(:a => {:valid => Integer}) }.to_not raise_error
    @args.a.should == 17
  end

  it "should allow nil if :allow_nil is set" do
    expect { @args = {:a => nil}.keyword_args(:a => {:valid => Integer}) }.to raise_error(ArgumentError)
    expect { @args = {:a => nil}.keyword_args(:a => {:valid => Integer, :allow_nil => true}) }.to_not raise_error
    @args.a.should be_nil
  end

  it "should accept enumerable if :enumerable" do
    @args = {:a => 1..10}.keyword_args(:a => :enumerable)
    @args.a.should == (1..10)
  end

  it "should coerce enumerable if :enumerable" do
    @args = {:a => 3}.keyword_args(:a => :enumerable)
    @args.a.should == [3]
  end

  it "should default enumerable if :enumerable" do
    @args = {}.keyword_args(:a => :enumerable)
    @args.a.should == []
  end

  it "should default enumerable if specified long form" do
    @args = {}.keyword_args(:a => { :enumerable => true })
    @args.a.should == []
  end

  it "should validate if :enumerable and :valid" do
    expect {@args = {:a => 3}.keyword_args(:a => { :enumerable => true, :valid => String })}.to raise_error(ArgumentError)
    expect {@args = {:a => ["OK", 3]}.keyword_args(:a => { :enumerable => true, :valid => String })}.to raise_error(ArgumentError)
    expect {@args = {:a => ["OK", "YY"]}.keyword_args(:a => { :enumerable => true, :valid => String })}.to_not raise_error
    @args.a.should == ["OK", "YY"]
  end

  it "should not include undefaulted arguments in hash" do
    @args = {:a =>3}.keyword_args(:a, :b)
    @args.include?(:a).should be_true
    @args.include?(:b).should_not be_true
  end


end
