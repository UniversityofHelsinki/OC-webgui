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
            'font' => '#333333',
            'statuses' => {
              'free' => '#37c837',
              'call' => '#ffff4d',
              'busy' => '#ff3333'
            }
          },
          'others' => {
            'sla' => 300,
            'working_day_start' => 8,
            'working_day_end' => 18,
            'animated' => true
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
            'font' => '#333333',
            'statuses' => {
              'free' => '#37c837',
              'call' => '#ffff4d',
              'busy' => '#ff3333'
            }
          },
          'others' => {
            'sla' => 300,
            'working_day_start' => 8,
            'working_day_end' => 18,
            'animated' => true
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
            'font' => '#000000',
            'statuses' => {
              'free' => '#37c837',
              'call' => '#ffff4d',
              'busy' => '#ff3333'
            },
          },
          'others' => {
            'sla' => 300,
            'working_day_start' => 8,
            'working_day_end' => 18,
            'animated' => true
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
          },
          'others' => {
            'animated' => false
          }
        }

        expected = {
          'colors' => {
            'background' => '#123456',
            'font' => '#654321',
            'statuses' => {
              'free' => '#37c837',
              'call' => '#ffff4d',
              'busy' => '#ff3333'
            }
          },
          'others' => {
            'sla' => 300,
            'working_day_start' => 8,
            'working_day_end' => 18,
            'animated' => false
          }
        }

        session['user_id'] = 2
        post :update, new_settings, format: :json
        expect(response).to be_successful
        data = JSON.parse(response.body)
        expect(data).to eq(expected)

        expect(User.find(2).settings).to eq(expected)
      end

      it 'fails with invalid colors' do
        new_settings = {
          'colors' => {
            'font' => '#333',
            'statuses' => {
              'free' => '#l0l0l'
            }
          }
        }

        expected = {
          'colors' => {
            'background' => '#ffffff',
            'font' => '#000000'
          }
        }

        error_response = {
          'colors' => {
            'font' => 'invalid color',
            'statuses' => {
              'free' => 'invalid color'
            }
          },
          'others' => {}
        }

        session['user_id'] = 2
        post :update, new_settings, format: :json
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)).to eq(error_response)

        expect(User.find(2).settings).to eq(expected)
      end

      it 'fails with invalid working day times' do
        new_settings = {
          'others' => {
            'working_day_start' => '12',
            'working_day_end' => '10'
          }
        }

        expected = {
          'colors' => {
            'background' => '#ffffff',
            'font' => '#000000'
          }
        }

        error_response = {
          "colors" => {},
          "others" => {
            "working_day_start" => "työpäivän alku ei voi olla työpäivän lopun jälkeen"
          },
        }

        session['user_id'] = 2
        post :update, new_settings, format: :json
        expect(response.status).to eq(400)
        expect(JSON.parse(response.body)).to eq(error_response)

        expect(User.find(2).settings).to eq(expected)
      end
    end
  end
end
