class CreateAnswer < ActiveRecord::Migration
  def change
    create_table :answers do |t|
    	t.string :answer_text
    	t.belongs_to :user, index: true
    	t.belongs_to :question, index: true
    	t.timestamps
    end
	end
end