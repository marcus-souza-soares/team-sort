class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :position
      t.boolean :status

      t.timestamps
    end
  end
end
