class ReportMailer < ActionMailer::Base
  default :from => "donotreply@thiscausesthat.org"
	def report(feedback)
		@feedback = feedback
		return mail(:to=>"thiscausesthat@gmail.com", :subject=>"New feedback submitted on ThisCausesThat")
	end

end
