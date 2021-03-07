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
                { user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }.to_json,
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
                { user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }.to_json,
                { 'CONTENT_TYPE' => 'application/json' })
      expect($sessions.sessions.length).to eq 1
      res = browser.post(
                '/signup',
                { user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }.to_json,
                { 'CONTENT_TYPE' => 'application/json' })
      expect(res.status).to eq 400
      expect($sessions.sessions.length).to eq 1
      expect(res.body).to eq({ result: false, msg: '既に登録されています' }.to_json)
    end
  end

  describe 'POST /challenge_token' do
    let(:browser) { Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application)) }
    context 'with request token for registered user' do
      before do
        $sessions = SessionManager.new()
        browser.post(
                  '/signup',
                  { user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }.to_json,
                  { 'CONTENT_TYPE' => 'application/json' })
      end

      it 'request token' do
        res = browser.post('/challenge_token', { user: 'namachan' }.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(res.status).to eq 200
        res_body = JSON.parse res.body
        expect(res_body["token"]).to match /\h{64}/
      end

      it 'unknown user' do
        res = browser.post('/challenge_token', { user: 'namahan' }.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(res.status).to eq 401
        res_body = JSON.parse res.body
        expect(res_body["result"]).to eq false
      end
    end

    context 'with no registered user' do
      before do
        $sessions = SessionManager.new()
      end
      it 'unknown user' do
        res = browser.post('/challenge_token', { user: 'namachan' }.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(res.status).to eq 401
        res_body = JSON.parse res.body
        expect(res_body["result"]).to eq false
      end
    end
  end

  describe 'POST /login' do
    let(:browser) { Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application)) }

    before do
      browser.post(
                '/signup',
                { user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }.to_json,
                { 'CONTENT_TYPE' => 'application/json' })
    end

    it 'skip chalenge' do
      browser2 = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
      res = browser2.post('/login', { token: '' }.to_json, { 'CONTENT_TYPE' => 'application/json' })
      expect(res.status).to eq 401
      res_body = JSON.parse res.body
      expect(res_body["result"]).to eq false
    end

    context 'with success of challenge_token request' do
      let(:token) do
        res = browser.post('/challenge_token', { user: 'namachan' }.to_json, { 'CONTENT_TYPE' => 'application/json' })
        res_body = JSON.parse res.body
        res_body["token"]
      end

      it 'login' do
        login_token = calc_login_response(token, 'DEADBEEF')
        res = browser.post(
                  '/login',
                  { token: login_token }.to_json,
                  { 'CONTENT_TYPE' => 'application/json' })
        expect(JSON.parse(res.body)['result']).to eq true
      end

      it 'wrong password' do
        login_token = calc_login_response(token, 'BADBEEF')
        res = browser.post('/login', { token: login_token }.to_json, { 'CONTENT_TYPE' => 'application/json' })
        expect(JSON.parse(res.body)['result']).to eq false
      end
    end
  end

  describe 'POST /polls/:id/votes' do
    let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }

    before do
      $polls = [poll]
    end

    context 'with sucess of login' do

      let(:browser) { Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application)) }
      before do
        browser.post(
                    '/signup',
                    { user: 'namachan', pass: 'DEADBEEF', salt: 'PUBKEY' }.to_json,
                    { 'CONTENT_TYPE' => 'application/json' })
        res = browser.post('/challenge_token', { user: 'namachan' }.to_json, { 'CONTENT_TYPE' => 'application/json' })
        res_body = JSON.parse res.body
        login_token = calc_login_response(res_body["token"], 'DEADBEEF')
        browser.post('/login', { token: login_token }.to_json, { 'CONTENT_TYPE' => 'application/json' })
      end

      context 'with valid id and params' do
        it 'adds a vote and redirects to /polls/:id' do
          res = nil
          expect {
            res = browser.post '/polls/0/votes', { candidate: 'Alice' }
          }.to change { poll.votes.size }.by(1)
          expect(res.status).to eq 303
          expect(res.original_headers['Location']).to match %r{/polls/0$}
        end
      end

      context 'with invalid id' do
        it 'responds 404 Not Found' do
          res = nil
          expect {
            res = browser.post '/polls/1/votes', { candidate: 'Alice' }
          }.not_to change { poll.votes.size }
          expect(res.status).to eq 404
        end
      end

      context 'with invalid params' do
        it 'responds 400 Bad Request' do
          res = nil
          expect {
            res = browser.post '/polls/0/votes', { voter: 'Miyoshi', candidate: 'INVALID' }
          }.not_to change { poll.votes.size }

          expect(res.status).to eq 400
        end
      end
    end
    context 'with no login info' do
      let(:browser) { Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application)) }
      context 'with valid id and params' do
        it 'be refused to add a votes to /polls/:id' do
          res = nil
          expect {
            res = browser.post '/polls/0/votes', { candidate: 'Alice' }
          }.to change { poll.votes.size }.by(0)
          expect(res.status).to eq 403
        end
      end
    end
  end

  describe 'GET /polls/:id/result' do
    let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }

    before do
      $polls = [poll]
    end

    context 'with valid id' do
      it 'responds 200 OK' do
        get '/polls/0/result'

        expect(last_response.status).to eq 200
      end
    end

    context 'with invalid id' do
      it 'responds 404 Not Found' do
        get '/polls/1/result'

        expect(last_response.status).to eq 404
      end
    end
  end
end
