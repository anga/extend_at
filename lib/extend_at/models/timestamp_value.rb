class TimestampValue < ActiveRecord::Base
  set_table_name "extend_at_timestamps"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end 
