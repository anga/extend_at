require File.expand_path('../models/all', __FILE__)

module ExtendModelAt
  class ModelManager
    def initialize(column_name,model, config)
      @column_name, @model, @config = column_name, model, config

      if not @model.new_record?
        @extend_at = ExtendAt.find_by_model_id_and_model_type @model.id, @model.class.to_s
      else
        @extend_at = ExtendAt.new
        @extend_at.save
      end
    end

    def assign(column,value)
      raise "#{value} is not valid" if not @model.send(:valid_type?, value, @config[column.to_sym].try(:[], :type))
      
      last_model = get_column_model column
      type_class = get_type_class @config[column.to_sym].try(:[], :type)

      if last_model.nil?
        eval "
        new_column = Column.new :extend_at_id => @extend_at.id
        new_column.save
        new_value = #{type_class}.new(:column => column, :value => value, :extend_at_column_id => new_column.id)
        new_value.save
        new_column.column_id = new_value.id
        new_column.save
        "
      else
        eval "last_model.value = value
        last_model.save"
      end
    end

    def get_value(column)
      model = get_column_model column #, get_type(column)
      model.try(:value)
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
      if type == :any or type.nil?
        return "AnyValue"
      elsif type == :binary
        return "BinaryValue"
      elsif type == :boolean
        return "BooleanValue"
      elsif type == :date
        return "DateValue"
      elsif type == :datetime
        return "DatetimeValue"
      elsif type == :decimal
        return "DecimalValue"
      elsif type == :float
        return "FloatValue"
      elsif type == :integer
        return "IntegerValue"
      elsif type == :string
        return "StringValue"
      elsif type == :text
        return "TextValue"
      elsif type == :time
        return "TimeValue"
      elsif type == :timestamp
        return "TimestampValue"
      else
        return "AnyValue"
      end
    end

    def update
      @extend_at.model_id = @model.id
      @extend_at.model_type = @model.class.to_s
      @extend_at.save
    end

    EQUIVALENCE_METHODS = {
      'lt' => 'lt',
      'lt_eq' => 'lteq',
      'eq' => 'eq',
      'gt' => 'gt',
      'gt_eq' => 'gteq',
      'match' => 'matches'
    }

    def search(column, method,value)
      type = get_type column
      type_class = get_type_class type
      equivalence_method = EQUIVALENCE_METHODS[method.to_s]
      "
      where(
          ExtendAt.arel_table.project('model_id').where(
            ExtendAt.arel_table[:model_type].eq(\"#{@model.class.name}\").and(
              ExtendAt.arel_table[:id].in(
                ::Column.arel_table.project('extend_at_id').where(
                  ::Column.arel_table[:id].in(
                    ::#{type_class}.arel_table.project('extend_at_column_id').where(
                      ::#{type_class}.arel_table[:column].eq(column).and(
                        ::#{type_class}.arel_table[:value].#{equivalence_method}(value)
                      )
                    )
                  )
                )
              )
            )
          ).to_sql
        )
      "
    end
  end
end
