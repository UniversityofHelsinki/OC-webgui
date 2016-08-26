RSpec.describe UsersController, type: :controller do
  render_views

  after(:all) do
    User.delete_all
  end

  it "index returns all users" do
    User.create(id: 1, username: "keke", password: "x")
    User.create(id: 2, username: "spede", password: "x", is_admin: true)
    get :index, format: :json
    user1 = {
      "id"=>1,
      "username"=>"keke",
      "is_admin"=>false,
      "agent_id"=>nil
    }
    user2 = {
      "id"=>2,
      "username"=>"spede",
      "is_admin"=>true,
      "agent_id"=>nil
    }
    expect(JSON.parse(response.body)).to include(user1)
    expect(JSON.parse(response.body)).to include(user2)
  end

  it "returns 403 if attempting to access create, edit or delete without logging in" do
    post :create, { username: "a", password: "b" }, format: :json
    expect(response.status).to eq(403)
    put :update, { id: 1, is_admin: true }, format: :json
    expect(response.status).to eq(403)
    delete :destroy, id: 1
    expect(response.status).to eq(403)
  end

  it "returns 403 if attempting to access create, edit or delete as non-admin" do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.new())
    post :create, { username: "a", password: "b" }, format: :json
    expect(response.status).to eq(403)
    put :update, { id: 1, is_admin: true }, format: :json
    expect(response.status).to eq(403)
    delete :destroy, id: 1
    expect(response.status).to eq(403)
  end

  context "when logged in as an admin" do
    it "allows creating new users" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.new(is_admin: true))
      post :create, { username: "a", password: "b", format: :json }
      expect(User.all.count).to eq(1)
    end

    it "allows deleting existing users" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.new(is_admin: true))
      User.create(id: 1, username: "keke", password: "x")
      expect(User.all.count).to eq(1)
      delete :destroy, id: 1
      expect(User.all.count).to eq(0)
    end

    it "allows updating existing users" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.new(is_admin: true))
      User.create(id: 1, username: "keke", password: "x", is_admin: false)
      expect(User.first.is_admin).to be(false)
      put :update, { id: 1, is_admin: true, format: :json }
      expect(User.first.is_admin).to be(true)
    end
  end
end
