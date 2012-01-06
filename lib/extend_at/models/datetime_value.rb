class DatetimeValue < ActiveRecord::Base
  set_table_name "extend_at_datetimes"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end 
