class TimeValue < ActiveRecord::Base
  set_table_name "extend_at_times"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end 
