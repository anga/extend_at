class DateValue < ActiveRecord::Base
  self.table_name = "extend_at_dates"
  belongs_to :extend_at_column, :class_name => 'Column', :foreign_key => 'extend_at_column_id'
end 
