class CreateExtendAtTables < ActiveRecord::Migration
  def up
    create_table :extend_at_strings do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.string :value
    end

    create_table :extend_at_texts do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.text :value
    end

    create_table :extend_at_integers do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.integer :value
    end

    create_table :extend_at_floats do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.float :value
    end

    create_table :extend_at_decimals do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.decimal :value
    end

    create_table :extend_at_datetimes do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.datetime :value
    end

    create_table :extend_at_timestamps do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.timestamp :value
    end

    create_table :extend_at_times do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.time :value
    end

    create_table :extend_at_dates do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.date :value
    end

    create_table :extend_at_binaries do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.binary :value
    end

    create_table :extend_at_booleans do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.boolean :value
    end

    create_table :extend_at_anies do |t|
      t.belongs_to :extend_at_column
      t.string :column
      t.text :value
    end
    
    create_table :extend_ats do |t|
      t.references :model, :polymorphic => true
    end

    create_table :extend_at_columns do |t|
      t.belongs_to :extend_at
      t.belongs_to :column, :polymorphic => true
    end
  end

  def down
    drop_table :extend_at_strings
    drop_table :extend_at_texts
    drop_table :extend_at_integers
    drop_table :extend_at_floats
    drop_table :extend_at_decimals
    drop_table :extend_at_datetimes
    drop_table :extend_at_timestamps
    drop_table :extend_at_times
    drop_table :extend_at_dates
    drop_table :extend_at_binaries
    drop_table :extend_at_booleans
    drop_table :extend_at_anies

    drop_table :extend_ats
    drop_table :extend_at_columns
  end
end
