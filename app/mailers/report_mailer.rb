class ReportMailer < ActionMailer::Base
  default :from => "donotreply@thiscausesthat.org"
	def report(feedback)
		@feedback = feedback
		return mail(:to=>"randomemailaddress", :subject=>"New feedback submitted on ThisCausesThat")
	end

	def notify(exception) #for reputation system
		@exception = exception
		return mail(:to=>"randomemailaddress", :subject=>"Reputation system -- Ignore this")
	end

end
