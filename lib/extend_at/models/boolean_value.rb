class BooleanValue < ActiveRecord::Base
  set_table_name "extend_at_booleans"
  belongs_to :extend_at_column, :class_name => 'Column', :foreign_key => 'extend_at_column_id'
end 
