class DailyContacts

	def initialize(team_name)
		@contacts = AgentStatus.where(open: false, team: team_name, status: ["Puhelu", "Chat"], created_at: Date.today.beginning_of_day..Date.today.end_of_day)
	end

	def get_contacts_between(starttime, endtime)
		return @contacts.select { |contact| contact.created_at >= Time.parse("#{Date.today} #{starttime} +0000") && contact.created_at <= Time.parse("#{Date.today} #{endtime} +0000") }.count
	end

end