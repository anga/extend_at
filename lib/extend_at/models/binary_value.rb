class BinaryValue < ActiveRecord::Base
  set_table_name "extend_at_binaries"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end 
