require_relative '../lib/authenticator'

RSpec.describe 'Authenticator' do


  it 'has a auth record' do
    auth = Authenticator.new()
    expect(auth.record).to eq ({})
  end

  describe '#register' do
    it 'register username, salt and encrypted password' do
      auth = Authenticator.new()
      auth.register('namachan', 'PUBKEY', 'PASS')
      expect(auth.record['namachan']).to eq ({salt: 'PUBKEY', pass: 'PASS'})
    end

    it 'if the username was already registered, throw exception' do
      auth = Authenticator.new()
      auth.register('namachan', 'PUBKEY', 'PASS')
      expect {auth.register('namachan', '', '')}.to raise_error Authenticator::AlreadyRegistered
    end
  end

  describe '#req_salt' do
    it 'request key by username' do
      auth = Authenticator.new()
      auth.register('namachan', 'PUBKEY', 'PASS')
      expect(auth.req_salt('namachan')).to eq 'PUBKEY'
    end
    it 'if the username was not registered, throw exception' do
      auth = Authenticator.new()
      auth.register('namachan', 'PUBKEY', 'PASS')
      expect{auth.req_salt('hogehoge')}.to raise_error Authenticator::UserNotFound
    end
  end
end
