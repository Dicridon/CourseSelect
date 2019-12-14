class AddCourseAttribute < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :open, :boolean, default: true
  end
end
