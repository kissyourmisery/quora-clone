class CreateQuestion < ActiveRecord::Migration
  def change
	  create_table :questions do |t|
	  	t.string :question_text
	  	t.belongs_to :user, index: true
	    t.timestamps
	  end
	end
end