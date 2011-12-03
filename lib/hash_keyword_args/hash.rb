require 'enumerable_hashify'

module HashKeywordArgs
  module Hash
    # given an argument hash and a description of acceptable keyword args and
    # their default values, checks validity of the arguments and raises any
    # errors, otherwise returns a new hash containing all arg values with
    # defaults filled in as needed.
    #
    # args = hash.keyword_args(:a, :b, :c,        # these are all optional args
    #                          :d => :optional,   # same as listing it the arg up front
    #                          :e => :required,   # raises an error if arg not provided
    #                          :f => "hello"      # default value
    #                          :g => [:x,:y,:z]   # valid values
    #                          :h => Integer      # valid type
    #                          :i => :enumerable  # expect/coerce an enumerable, check all items, default is []
    #                          :j => { :valid => Integer, :allow_nil => true}   # Integer or nil
    #                          :j => { :valid => [:x,:y,:z], :default => :x, :required => true }   # combo
    #                          )
    #
    # by default this will raise an error if the hash contains any keys not
    # listed.  however, if :OTHERS is specified as a keyword arg, that test
    # will be disabled and any other key/value pairs will be passed through.
    #
    # Returns a Struct whose values are the 
    #
    def keyword_args(*args)
      argshash = args[-1].is_a?(Hash) ? args.pop : {}
      argshash = args.hashify(:optional).merge(argshash)
      others_OK = argshash.delete(:OTHERS)
      ret = {}

      # defaults, required, and checked
      required = []
      check = {}
      argshash.each do |key, val|
        # construct fleshed-out attribute hash for all args
        attrs = case val
                when Hash
                  val[:default] ||= [] if val[:enumerable]
                  val
                when :required
                  { :required => true }
                when :optional
                  {}
                when :enumerable
                  { :enumerable => true, :default => [] }
                when Array
                  { :valid => val }
                when Class, Module
                  { :valid => val }
                else
                  { :default => val }
                end

        # extract required flag, validity checks, and default vlues from attribute hash
        required << key if attrs[:required]
        check[key] = case valid = attrs[:valid]
                     when Enumerable
                       [:one_of, valid]
                     when Class, Module
                       [:is_a, valid]
                     else
                       [:ok]
                     end
        check[key][2] = [:allow_nil, :enumerable].select{|mod| attrs[mod]}
        ret[key] = attrs[:default] if attrs.include?(:default)
      end

      # check validity of keys
      unless others_OK or (others = self.keys - argshash.keys).empty?
        raise ArgumentError, "Invalid keyword arg#{others.length>1 && "s" or ""} #{others.collect{|a| a.inspect}.join(', ')}", caller
      end

      # process values, checking validity
      self.each do |key, val|
        code, valid, mods = check[key]
        mods ||= []
        val = [ val ] unless mods.include?(:enumerable) and val.is_a?(Enumerable)
        ok = val.all? { |v|
          if mods.include?(:allow_nil) and v.nil?
            true
          else
            case code
            when nil     then true      # for OTHERS args, there's no code
            when :ok     then true
            when :one_of then valid.include?(v)
            when :is_a   then v.is_a?(valid)
            end
          end
        }
        val = val.first unless mods.include?(:enumerable)
        raise ArgumentError, "Invalid value for keyword arg #{key.inspect} => #{val.inspect}", caller unless ok
        ret[key] = val
        required.delete(key)
      end

      unless required.empty?
        raise ArgumentError, "Missing required keyword arg#{required.length>1 && "s" or ""} #{required.collect{|a| a.inspect}.join(', ')}", caller
      end

      (class << ret ; self ; end).class_eval do
        argshash.keys.each do |key|
          define_method(key) do
            self[key]
          end
        end
      end

      ret
    end


  end
end
