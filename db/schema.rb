# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2016_11_09_084337) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string "name"
    t.string "course_code"
    t.string "course_type"
    t.string "teaching_type"
    t.string "exam_type"
    t.string "credit"
    t.integer "limit_num"
    t.integer "student_num", default: 0
    t.string "class_room"
    t.string "course_time"
    t.string "course_week"
    t.bigint "teacher_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "open", default: true
    t.index ["teacher_id"], name: "index_courses_on_teacher_id"
  end

  create_table "grades", force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "user_id"
    t.integer "grade"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id"], name: "index_grades_on_course_id"
    t.index ["user_id"], name: "index_grades_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "num"
    t.string "major"
    t.string "department"
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.boolean "teacher", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
