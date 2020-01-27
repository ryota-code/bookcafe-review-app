require 'rails_helper'

describe UsersController do
  describe 'GET #show' do
    it 'assigns @user' do
      user = create(:user)
      get :show, params: { id: user }
      expect(assigns(:user)).to eq user
    end
  end
end
