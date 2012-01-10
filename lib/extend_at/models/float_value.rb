class FloatValue < ActiveRecord::Base
  set_table_name "extend_at_floats"
  belongs_to :extend_at_column, :class_name => 'Column', :foreign_key => 'extend_at_column_id'
end 
