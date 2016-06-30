require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  before do
    User.destroy_all
    @valid_user = User.create(id: 1, username: 'olemas', password: 'sala1nen')
  end

  describe 'SessionController#create' do
    it 'fails with non-existing username' do
      post :create, { 'username' => 'eioo', 'password' => 'sala1nen' }, format: :json
      expect(response.status).to eq(401)
      data = JSON.parse(response.body)
      expect(data['error']).to eq('invalid username')
      expect(session['user_id']).to be_nil
      expect(subject.current_user).to be_nil
    end

    it 'fails with wrong password' do
      post :create, { 'username' => 'olemas', 'password' => 'vaara' }, format: :json
      expect(response.status).to eq(401)
      data = JSON.parse(response.body)
      expect(data['error']).to eq('wrong password')
      expect(session['user_id']).to be_nil
      expect(subject.current_user).to be_nil
    end

    it 'succeeds with correct password' do
      post :create, { 'username' => 'olemas', 'password' => 'sala1nen' }, format: :json
      expect(response).to be_successful
      data = JSON.parse(response.body)
      expect(data['username']).to eq('olemas')
      expect(session['user_id']).to eq(1)
      expect(subject.current_user).to eq(@valid_user)
    end
  end

  describe 'SessionController#destroy' do
    it 'does nothing when not logged in' do
      expect(session['user_id']).to be_nil
      delete :destroy
      expect(response).to be_successful
      expect(session['user_id']).to be_nil
      expect(subject.current_user).to be_nil
    end

    it 'logs out authenticated user' do
      post :create, { 'username' => 'olemas', 'password' => 'sala1nen' }, format: :json
      expect(response).to be_successful
      expect(session['user_id']).to eq(1)

      delete :destroy
      expect(response).to be_successful
      expect(session['user_id']).to be_nil
      expect(subject.current_user).to be_nil
    end
  end
end
