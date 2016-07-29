require 'rails_helper'

RSpec.describe SettingsController, type: :controller do
  before do
    User.create(id: 1, username: 'puuttuu', password: '1234')
    User.create(id: 2, username: 'asetus', password: '4321',
                settings: {
                  colors: {
                    background: '#ffffff',
                    font: '#000000'
                  }
                })
  end

  describe 'SettingsController#get' do
    context 'not logged in' do
      it 'returns defaults' do
        expected = {
          'colors' => {
            'background' => '#87aade',
            'font' => '#333333'
          }
        }
        get :get, format: :json
        data = JSON.parse(response.body)
        expect(data).to eq(expected)
      end
    end

    context 'logged in as user without settings' do
      it 'returns defaults' do
        expected = {
          'colors' => {
            'background' => '#87aade',
            'font' => '#333333'
          }
        }
        session['user_id'] = 1
        get :get, format: :json
        data = JSON.parse(response.body)
        expect(data).to eq(expected)
      end
    end

    context 'logged in as user with settings' do
      it 'returns defaults' do
        expected = {
          'colors' => {
            'background' => '#ffffff',
            'font' => '#000000'
          }
        }
        session['user_id'] = 2
        get :get, format: :json
        data = JSON.parse(response.body)
        expect(data).to eq(expected)
      end
    end
  end

  describe 'SettingsController#update' do
    context 'not logged in' do
      it 'returns defaults' do
        post :update, format: :json
        expect(response.status).to eq(401)
        expect(JSON.parse(response.body)['error']).to eq('not logged in')
      end
    end

    context 'logged in' do
      it 'updates settings' do
        new_settings = {
          'colors' => {
            'background' => '#123456',
            'font' => '#654321'
          }
        }

        session['user_id'] = 2
        post :update, new_settings, format: :json
        expect(response).to be_successful
        data = JSON.parse(response.body)
        expect(data).to eq(new_settings)

        expect(User.find(2).settings).to eq(new_settings)
      end
    end
  end
end
