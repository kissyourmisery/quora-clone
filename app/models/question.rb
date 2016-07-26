class Question < ActiveRecord::Base

has_many :answers
belongs_to :user
has_many :question_votes

	def count_upvotes
		self.question_votes.where(vote: 1).count
	end

	def count_downvotes
		self.question_votes.where(vote: 0).count
	end

end