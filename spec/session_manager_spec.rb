require_relative '../lib/session_manager'
require_relative '../lib/authenticator'
require_relative 'util'

RSpec.describe 'SessionManager' do
  it 'session manager has sessions and a authenticator' do
    session_manager = SessionManager.new()
    expect(session_manager.sessions).to eq ({})
    expect(session_manager.authenticator.record).to eq ({})
  end

  describe '#signup' do
    it 'signup and login' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D')
      expect(session_manager.sessions['SESS']).to eq ({ user: 'USER', login: true, token: nil, payload: 'D' })
      expect(session_manager.authenticator.record).to eq ({ 'USER' => ({ salt: 'PUBKEY', pass: 'DEADBEEF' }) })
    end

    it 'if already registered, throw exception' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D1')
      expect {
session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D2') }.to raise_error Authenticator::AlreadyRegistered
      expect(session_manager.sessions.size).to eq 1
      expect(session_manager.authenticator.record.size).to eq 1
    end
  end

  describe '#start_login' do
    it 'return salt and one tine token' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D')
      res1 = session_manager.start_login('SESS2', 'USER')
      expect(res1[:salt]).to eq 'PUBKEY'
      expect(res1[:token].size).to eq 64
      expect(res1[:payload]).to eq nil
    end

    it 'token is different every time' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D1')
      res1 = session_manager.start_login('SESS2', 'USER')
      res2 = session_manager.start_login('SESS3', 'USER')
      expect(res1[:token]).not_to eq res2[:token]
    end

    it 'if user is not registered, throw error' do
      session_manager = SessionManager.new()
      expect { session_manager.start_login('SESS2', 'USER') }.to raise_error Authenticator::UserNotFound
    end

    it 'session has login state' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D')
      session_manager.start_login('SESS1', 'USER')
      expect(session_manager.sessions['SESS1'][:user]).to eq 'USER'
      expect(session_manager.sessions['SESS1'][:login]).to eq false
      expect(session_manager.sessions['SESS1'][:token].size).to eq 64
      expect(session_manager.sessions['SESS1'][:payload]).to eq nil
    end

    it 'login session can be overwritten' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER1', 'PUBKEY1', 'DEADBEEF1', 'D1')
      session_manager.signup('SESS', 'USER2', 'PUBKEY2', 'DEADBEEF2', 'D2')
      session_manager.start_login('SESS', 'USER1')
      session_manager.start_login('SESS', 'USER2')
      expect(session_manager.sessions['SESS'][:user]).to eq 'USER2'
      expect(session_manager.sessions['SESS'][:login]).to eq false
      expect(session_manager.sessions['SESS'][:token].size).to eq 64
      expect(session_manager.sessions['SESS'][:payload]).to eq 'D2'
    end
  end

  describe  '#request_info' do
    it 'adapt guest mode' do
      session_manager = SessionManager.new()
      expect(session_manager.request_info('SESS')).to eq ({ login: false, payload: nil, user: nil })
    end
  end

  describe '#confirm_login' do
    it 'login with HMAC' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D1')
      res = session_manager.start_login('SESS1', 'USER')
      token = res[:token]
      login_token = calc_login_response(token, 'DEADBEEF')
      session_manager.confirm_login('SESS1', login_token, 'D2')
      expect(session_manager.sessions['SESS1'][:login]).to eq true
      expect(session_manager.sessions['SESS1'][:payload]).to eq 'D2'
    end

    it 'failed to login' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D1')
      res = session_manager.start_login('SESS1', 'USER')
      token = res[:token]
      login_token = calc_login_response(token, 'BADBEEF')
      expect { session_manager.confirm_login('SESS1', login_token, 'D') }.to raise_error SessionManager::WrongPassword
    end

    it 'failed to login' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D1')
      login_token = calc_login_response('', 'BADBEEF')
      expect { session_manager.confirm_login('SESS1', login_token, 'D') }.to raise_error SessionManager::UnknownSession
    end
  end

  describe '#logout' do
    it 'logout' do
      session_manager = SessionManager.new()
      session_manager.signup('SESS', 'USER', 'PUBKEY', 'DEADBEEF', 'D1')
      res = session_manager.start_login('SESS1', 'USER')
      token = res[:token]
      login_token = calc_login_response(token, 'DEADBEEF')
      session_manager.confirm_login('SESS1', login_token, 'D2')
      session_manager.logout('SESS1')
      expect(session_manager.sessions['SESS1'][:login]).to eq false
      expect(session_manager.sessions['SESS1'][:payload]).to eq 'D2'
    end
  end
end
