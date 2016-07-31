RSpec.describe UsersController, type: :controller do
  after(:all) do
    User.delete_all
    Agent.delete_all
  end

  before (:all) do
    Agent.create(id: 1, first_name: 'a', last_name: 'b')
    User.create(username: 'aa', agent_id: 1, password: 'x')
    User.create(username: 'bb', password: 'x')
  end
  
  it "returns 403 if attempting to access create, edit or delete without logging in" do
    post :create, format: :json
    expect(response.status).to eq(403)
    post :update, format: :json
    expect(response.status).to eq(403)
    post :destroy, format: :json
    expect(response.status).to eq(403)
  end

  it "returns 403 if attempting to access create, edit or delete as non-admin" do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.new())
    post :create, format: :json
    expect(response.status).to eq(403)
    post :update, format: :json
    expect(response.status).to eq(403)
    post :destroy, format: :json
    expect(response.status).to eq(403)
  end
end
