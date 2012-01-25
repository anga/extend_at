module ExtendModelAt
  class TableManager
    def initialize
      @config = {}
    end
    
    [:any, :binary, :boolean, :date, :datetime, :decimal, :float, :integer, :string, :text, :time, :timestamp].each do |function|
      define_method(function.to_s) do |column_name, options={}|
        @config[column_name.to_sym] = options.merge!({:type => function})
        nil
      end
    end

    protected
    
    def config
      return @config
    end
  end
end