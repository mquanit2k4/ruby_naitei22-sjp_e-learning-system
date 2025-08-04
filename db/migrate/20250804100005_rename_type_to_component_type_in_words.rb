class RenameTypeToComponentTypeInWords < ActiveRecord::Migration[7.0]
  def change
    rename_column :words, :type, :word_type
    rename_column :components, :type, :component_type
    rename_column :questions, :type, :question_type
  end
end
