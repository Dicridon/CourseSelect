class CreateGrades < ActiveRecord::Migration[6.0]
  def change
    create_table :grades do |t|
      t.belongs_to :course, index: true
      t.belongs_to :user, index: true
      t.integer :grade
      t.timestamps null: false
    end
  end
end
