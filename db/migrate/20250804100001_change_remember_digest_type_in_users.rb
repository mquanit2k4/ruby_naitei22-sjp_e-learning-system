class ChangeRememberDigestTypeInUsers < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :remember_digest, :string
  end
end
