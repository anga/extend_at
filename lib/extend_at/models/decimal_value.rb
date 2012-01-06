class DecimalValue < ActiveRecord::Base
  set_table_name "extend_at_decimals"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end 
