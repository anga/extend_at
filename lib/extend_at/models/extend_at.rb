class ExtendAt < ActiveRecord::Base
  set_table_name "extend_ats"
  belongs_to :model, :polymorphic => true
  has_many :extend_at_columns
  has_many :columns, :through => :extend_at_columns
end
