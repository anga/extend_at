class FloatValue < ActiveRecord::Base
  set_table_name "extend_at_floats"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end 
