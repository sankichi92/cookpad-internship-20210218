require 'sinatra/test_helpers'
require_relative '../app'
require 'rack'

RSpec.describe 'PollApp' do
  include Sinatra::TestHelpers

  before do
    set_app Sinatra::Application
    $polls = []
  end

  describe 'GET /' do
    it 'responds 200 OK' do
      get '/'

      expect(last_response.status).to eq 200
    end
  end

  describe 'GET /polls/:id' do
    let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }

    before do
      $polls = [poll]
    end

    context 'with valid id' do
      it 'responds 200 OK' do
        get '/polls/0'

        expect(last_response.status).to eq 200
      end
    end

    context 'with invalid id' do
      it 'responds 404 Not Found' do
        get '/polls/1'

        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'GET /polls/:id/result' do
    let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }

    before do
      poll.add_vote(Vote.new('Nakano', 'Alice'))
      $polls = [poll]
    end

    context 'with valid id' do
      it 'responds 200 OK' do
        get '/polls/0'

        expect(last_response.status).to eq 200
      end
    end

    context 'with invalid id' do
      it 'responds 404 Not Found' do
        get '/polls/1'

        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'POST /signup' do
    let(:session_manager) { SessionManager.new() }
    before do
      $sessions = session_manager
    end
    it 'signup' do
      browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      expect($sessions.sessions.length).to eq 0
      res = browser.post(
                '/signup',
                JSON.generate({ user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }),
                { 'CONTENT_TYPE' => 'application/json' })
      expect(res.status).to eq 200
      expect($sessions.sessions.length).to eq 1
      expect(res.body).to eq({ result: true }.to_json)
    end
    it 'already registered' do
      browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      expect($sessions.sessions.length).to eq 0
      res = browser.post(
                '/signup',
                JSON.generate({ user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }),
                { 'CONTENT_TYPE' => 'application/json' })
      expect($sessions.sessions.length).to eq 1
      res = browser.post(
                '/signup',
                JSON.generate({ user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }),
                { 'CONTENT_TYPE' => 'application/json' })
      expect(res.status).to eq 400
      expect($sessions.sessions.length).to eq 1
      expect(res.body).to eq({ result: false, msg: '既に登録されています' }.to_json)
    end
  end

  describe 'POS /login' do
    it 'login' do
      browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      res = browser.post(
                '/signup',
                JSON.generate({ user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }),
                { 'CONTENT_TYPE' => 'application/json' })
      res = browser.post(
                '/challenge_token',
                JSON.generate({ user: 'namachan' }),
                { 'CONTENT_TYPE' => 'application/json' })
      expect(res.status).to eq 200
      res_body = JSON.parse res.body
      expect(res_body["token"].size).to eq 64
      login_token = calc_login_response(res_body["token"], 'DEADBEEF')
      res = browser.post(
                '/login',
                JSON.generate({ token: login_token }),
                { 'CONTENT_TYPE' => 'application/json' })
      expect(JSON.parse(res.body)['result']).to eq true
    end

    it 'wrong password' do
      browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      res = browser.post(
                '/signup',
                JSON.generate({ user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }),
                { 'CONTENT_TYPE' => 'application/json' })
      res = browser.post('/challenge_token', JSON.generate({ user: 'namachan' }), { 'CONTENT_TYPE' => 'application/json' })
      expect(res.status).to eq 200
      res_body = JSON.parse res.body
      expect(res_body["token"].size).to eq 64
      login_token = calc_login_response(res_body["token"], 'BADBEEF')
      res = browser.post('/login', JSON.generate({ token: login_token }), { 'CONTENT_TYPE' => 'application/json' })
      expect(JSON.parse(res.body)['result']).to eq false
    end

    it 'unknown user' do
      browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      res = browser.post(
                '/signup',
                JSON.generate({ user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }),
                { 'CONTENT_TYPE' => 'application/json' })
      res = browser.post('/challenge_token', JSON.generate({ user: 'namahan' }), { 'CONTENT_TYPE' => 'application/json' })
      expect(res.status).to eq 401
      res_body = JSON.parse res.body
      expect(res_body["result"]).to eq false
    end

    it 'skip chalenge' do
      browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      res = browser.post('/challenge_token', JSON.generate({ user: 'namahan' }), { 'CONTENT_TYPE' => 'application/json' })
      expect(res.status).to eq 401
      res_body = JSON.parse res.body
      expect(res_body["result"]).to eq false
      browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      res = browser.post('/login', JSON.generate({ token: '' }), { 'CONTENT_TYPE' => 'application/json' })
      expect(res.status).to eq 401
      res_body = JSON.parse res.body
      expect(res_body["result"]).to eq false
    end
  end

  describe 'POST /polls/:id/votes' do
    let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }

    before do
      $polls = [poll]
    end

    context 'with valid id and params' do
      it 'adds a vote and redirects to /polls/:id' do
        browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
        browser.post(
                    '/signup',
                    JSON.generate({ user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }),
                    { 'CONTENT_TYPE' => 'application/json' })
        res = browser.post('/challenge_token', JSON.generate({ user: 'namachan' }), { 'CONTENT_TYPE' => 'application/json' })
        res_body = JSON.parse res.body
        login_token = calc_login_response(res_body["token"], 'DEADBEEF')
        browser.post(
                    '/login',
                    JSON.generate({ token: login_token }),
                    { 'CONTENT_TYPE' => 'application/json' })
        res = nil
        expect {
          res = browser.post '/polls/0/votes', { candidate: 'Alice' }
        }.to change { poll.votes.size }.by(1)
        expect(res.status).to eq 303
        expect(res.original_headers['Location']).to match %r{/polls/0$}
      end
    end

    context 'with invalid id' do
      browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      it 'responds 404 Not Found' do
        browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
        browser.post('/signup', JSON.generate({ user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }),
{ 'CONTENT_TYPE' => 'application/json' })
        res = browser.post('/challenge_token', JSON.generate({ user: 'namachan' }), { 'CONTENT_TYPE' => 'application/json' })
        res_body = JSON.parse res.body
        login_token = calc_login_response(res_body["token"], 'DEADBEEF')
        browser.post(
                    '/login',
                    JSON.generate({ token: login_token }),
                    { 'CONTENT_TYPE' => 'application/json' })
        res = nil
        expect {
          res = browser.post '/polls/1/votes', { candidate: 'Alice' }
        }.not_to change { poll.votes.size }
        expect(res.status).to eq 404
      end
    end

    context 'with invalid params' do
      browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      it 'responds 400 Bad Request' do
        browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
        browser.post(
                    '/signup',
                    JSON.generate({ user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }),
                    { 'CONTENT_TYPE' => 'application/json' })
        res = browser.post('/challenge_token', JSON.generate({ user: 'namachan' }), { 'CONTENT_TYPE' => 'application/json' })
        res_body = JSON.parse res.body
        login_token = calc_login_response(res_body["token"], 'DEADBEEF')
        browser.post('/login', JSON.generate({ token: login_token }), { 'CONTENT_TYPE' => 'application/json' })
        res = nil
        expect {
          res = browser.post '/polls/0/votes', { voter: 'Miyoshi', candidate: 'INVALID' }
        }.not_to change { poll.votes.size }

        expect(res.status).to eq 400
      end
    end
  end
end
