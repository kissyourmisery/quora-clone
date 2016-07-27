class Answer < ActiveRecord::Base

belongs_to :user
belongs_to :question
has_many :answer_votes

	def count_upvotes
		self.answer_votes.where(vote: 1).count
	end

	def count_downvotes
		self.answer_votes.where(vote: 0).count
	end

end