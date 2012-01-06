class DateValue < ActiveRecord::Base
  set_table_name "extend_at_dates"
  belongs_to :extend_at, :class_name => 'ExtendAt'
end 
