require File.expand_path('../structure', __FILE__)

module ExtendModelAt
  class Environment
    def initialize
      @config = {}
      @config[:has_one] = {}
      @config[:has_many] = {}
      @config[:belongs_to] = {}
      @config[:static] = false
    end
    
    def run(env=nil, model=nil)
      instance_exec env
    end

    [:has_one, :has_many, :belongs_to].each do |function|
      define_method(function.to_s) do |name, opts={}|
        @config[function][name.to_sym] = opts
      end
    end

    # == Defining columns
    # You cand define the _table structure_ using the function +structure+
    #
    #    structure :static => true do |t|
    #      t.string      :name
    #      t.integer     :loggin_counter, :default => 0
    #      t.belongs_to  :account
    #      t.belongs_to  :owner, :polymorphic => true
    #    end
    def structure(options={})
      @config[:columns] = Structure.new.run yield
      @config[:static] = options[:static]
    end

    protected
    def config
      @config
    end
  end
end