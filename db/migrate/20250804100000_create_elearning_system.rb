# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

class CreateElearningSystem < ActiveRecord::Migration[7.0]
  def change
    # Bảng 'users' để lưu trữ thông tin người dùng
    create_table :users do |t|
      t.string :name, limit: 100
      t.string :email, limit: 100, null: false
      t.string :password_digest, limit: 255, null: false
      t.date :birthday
      t.integer :gender, null: true
      t.integer :role, null: false, default: 0
      t.bigint :remember_digest, null: false
      t.timestamps
    end
    add_index :users, :email, unique: true

    # Bảng 'courses' để lưu trữ các khóa học
    create_table :courses do |t|
      t.string :title, limit: 255, null: false
      t.text :description, null: false
      t.references :created_by, foreign_key: { to_table: :users }
      t.timestamps
    end

    # Bảng 'lessons' để lưu trữ các bài học trong một khóa học
    create_table :lessons do |t|
      t.references :course, null: false, foreign_key: true
      t.string :title, limit: 255, null: false
      t.text :description, null: false
      t.integer :position, null: false
      t.references :created_by, foreign_key: { to_table: :users }
      t.timestamps
    end

    # Bảng 'words' để lưu trữ các từ vựng
    create_table :words do |t|
      t.text :content, null: false
      t.text :meaning, null: false
      t.integer :type, null: false
      t.timestamps
    end

    # Bảng 'tests' để lưu trữ thông tin các bài kiểm tra
    create_table :tests do |t|
      t.text :name, null: false
      t.text :description, null: false
      t.integer :duration, null: false
      t.integer :max_attempts, null: false
      t.timestamps
    end

    # Bảng 'questions' để lưu trữ các câu hỏi trong bài kiểm tra
    create_table :questions do |t|
      t.references :test, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :type, null: false
      t.timestamps
    end

    # Bảng 'answers' để lưu trữ các câu trả lời cho câu hỏi
    create_table :answers do |t|
      t.references :question, null: false, foreign_key: true
      t.string :content, limit: 255, null: false
      t.boolean :correct, null: false
      t.timestamps
    end

    # Bảng 'components' để định nghĩa các thành phần của một bài học
    create_table :components do |t|
      t.references :lesson, null: false, foreign_key: true
      t.integer :type, null: false
      t.references :test, null: true, foreign_key: true
      t.references :word, null: true, foreign_key: true
      t.text :content, null: true
      t.bigint :index_in_lesson, null: false
      t.timestamps
    end

    # Bảng 'user_courses' để theo dõi tiến trình khóa học của người dùng
    create_table :user_courses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :enrolment_status, null: false, default: 0
      t.integer :progress, null: false
      t.timestamps
    end

    # Bảng 'user_lessons' để theo dõi tiến trình bài học của người dùng
    create_table :user_lessons do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lesson, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :grade, null: false
      t.datetime :completed_at
      t.timestamps
    end

    # Bảng 'admin_course_managers' để quản lý admin của khóa học
    create_table :admin_course_managers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.timestamps
    end

    # Bảng 'user_words' để lưu các từ vựng của người dùng
    create_table :user_words do |t|
      t.references :user, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.timestamps
    end

    # Bảng 'test_results' để lưu kết quả bài kiểm tra của người dùng
    create_table :test_results do |t|
      t.references :user, null: false, foreign_key: true
      t.references :component, null: false, foreign_key: true
      t.integer :attempt_number, null: false
      t.json :user_answers, null: false
      t.integer :mark, null: false
      t.integer :status, null: false
      t.timestamps
    end
  end
end
