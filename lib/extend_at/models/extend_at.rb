class ExtendAt < ActiveRecord::Base
  set_table_name "extend_ats"
  belongs_to :model, :polymorphic => true
  has_many :extend_at_columns, :source => :extend_at, :class_name => 'Column'
#   has_many :columns, :through => :extend_at_columns, :source => :column
end
