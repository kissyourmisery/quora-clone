class CreateQuestionVote < ActiveRecord::Migration
  def change
	  create_table :question_votes do |t|
    	t.string :vote
    	t.belongs_to :question, index: true
    	t.belongs_to :user, index: true
      t.timestamps
    end
	end
end

