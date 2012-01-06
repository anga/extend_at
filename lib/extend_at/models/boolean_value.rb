class BooleanValue < ActiveRecord::Base
  set_table_name "extend_at_booleans"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end 
