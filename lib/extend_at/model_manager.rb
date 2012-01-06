require File.expand_path('../models/all', __FILE__)

module ExtendModelAt
  class ModelManager
    def initialize(column_name,model, config)
      @column_name, @model, @config = column_name, model, config
      puts "config: #{@config}"
    end

    def assign(column,value)
      raise "#{value} is not valid" if @config[column.to_sym].kind_of? Hash and value.class != @config[column.to_sym][:type]
      
      last_model = get_column_model column
      type_class = get_type_class @config[column.to_sym][:type]
      
      if @extend_at.nil?
        @extend_at = ExtendAt.new :model => @model
        @extend_at.save
      end

      if last_model.nil?
        eval "@extend_at.columns << #{type_class}.new :column => column, :value => value"
      else
        eval "last_model.value = value
        last_model.save"
      end
    end

    def get_value(column)
      model = get_column_model column, get_type(column)
      model.value
    end

    protected
    def get_column_model(column)
      type = get_type column
      type_class = get_type_class type
      eval "::#{type_class}.where(
        ::#{type_class}.arel_table[:column].eq(column).and(
          ::#{type_class}.arel_table[:extend_at_column_id].in(
            ::Column.arel_table.project(:id).where(
              ::Column.arel_table[:extend_at_id].eq(@extend_at.id)
            )
          )
        )
      ).try(:first)"
    end

    def get_type(column)
      if @config[column.to_sym].kind_of? Hash
         @config[column.to_sym][:type]
      else
        nil
      end
    end

    def get_type_class(type)
      type = type
      if type == Fixnum
        return "IntegerValue"
      elsif type == Float
        return "FloatValue"
      elsif type == String
        return "StringValue"
      elsif type == :text
        return "TextValue"
      else
        return "AnyValue"
      end
    end
  end
end
