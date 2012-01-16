class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.text :private_info
      t.text :public_info
      t.text :configuration

      t.timestamps
    end
  end
end
