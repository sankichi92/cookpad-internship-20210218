require 'sinatra/test_helpers'
require_relative 'spec_helper'
require 'sinatra'

RSpec.describe 'System' do
  include Sinatra::TestHelpers

  before do
    set_app Sinatra::Application
    $polls = []
  end

  context 'with no login' do
    it 'GET /', js: true do
      visit 'localhost:4567/'
      expect(page).to have_content('ログイン')
      expect(page).to_not have_content('追加')
      expect(page).to_not have_content('登録')
    end

    it 'GET /polls/0', js: true do
      visit 'localhost:4567/polls/0'
      expect(page).to_not have_content('投票する')
    end

    it 'GET /login' do
      visit 'localhost:4567/login'
      expect(page).to have_content('登録')
    end
  end

  context 'signup' do
    it 'GET /signup' do
      visit 'localhost:4567/signup'
      fill_in 'signup-username', with: 'namachan'
      fill_in 'signup-password', with: 'the-password'
      find_by_id('signup-confirm').click
      expect(current_path).to eq('/')
      expect(page).to have_content('登録')
      expect(page).to have_content('追加')
    end

    context 'duplicated signup' do
      it 'GET /signup' do
        visit 'localhost:4567/signup'
        fill_in 'signup-username', with: 'namachan'
        fill_in 'signup-password', with: 'the-password'
        find_by_id('signup-confirm').click
        msg = accept_confirm {}
        expect(msg).to eq ('既に登録されています')
        expect(current_path).to eq('/signup')
      end
    end
  end

  context 'unregistered username' do
    it 'GET /login' do
      visit 'localhost:4567/login'
      fill_in 'login-username', with: 'namahan'
      fill_in 'login-password', with: 'the-password'
      find_by_id('login-confirm').click
      msg = accept_confirm {}
      expect(msg).to eq ('ユーザが存在しません')
      expect(current_path).to eq('/login')
    end

    it 'GET /polls/0', js: true do
      visit 'localhost:4567/polls/0'
      expect(page).to_not have_content('投票する')
    end

    it 'GET /login' do
      visit 'localhost:4567/login'
      expect(page).to have_content('登録')
    end
  end

  context 'login' do
    it 'GET /login' do
      visit 'localhost:4567/login'
      fill_in 'login-username', with: 'namachan'
      fill_in 'login-password', with: 'the-password'
      find_by_id('login-confirm').click
      expect(current_path).to eq('/')
      expect(page).to have_content('登録')
      expect(page).to have_content('追加')
      visit 'localhost:4567/polls/0'
      expect(page).to have_content('投票する')
    end
  end
end
