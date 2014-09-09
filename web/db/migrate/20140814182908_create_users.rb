class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t| 
      t.string :email, :null => false
      t.string :password_digest, :null => false
      t.integer :role, :default=>0, :null => false
      t.timestamps
    end
    
    add_index :users, :email, unique: true
       
    create_table :user_tokens do |t|
      t.integer :user_id
      t.string :access_token
      t.datetime :expired_at
      t.datetime :created_at
    end
    
    add_index :user_tokens, :access_token, unique: true
  end
end
