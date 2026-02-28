class ChangeCryptedPasswordNullInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :crypted_password, true
  end
end
