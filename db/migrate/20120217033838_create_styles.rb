class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.string :stylesheet
      t.string :css
      t.string :name

      t.timestamps
    end
  end
end
