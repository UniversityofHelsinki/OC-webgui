# API for OC Agent status data
class PersonalStatusController < ApplicationController
  def index
    agent_id = params[:agent_id]
    contacts = Contact.where(agent_id: agent_id)
    render json: contacts
  end
end
