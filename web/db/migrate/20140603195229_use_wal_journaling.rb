class UseWalJournaling < ActiveRecord::Migration
  disable_ddl_transaction!
  
  def change
    reversible do |dir|
      dir.up do
        execute "PRAGMA journal_mode = WAL"
      end
      
      dir.down do
        execute "PRAGMA journal_mode = DELETE"
      end
    end
  end
end
