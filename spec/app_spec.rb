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

  describe 'POST /polls/:id/votes' do
    let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }

    before do
      $polls = [poll]
    end

    context 'with valid id and params' do
      it 'adds a vote and redirects to /polls/:id' do
        browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
        browser.post '/login', { username: 'Miyoshi' }
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
        browser.post '/login', { username: 'Miyoshi' }
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
        browser.post '/login', { username: 'Miyoshi' }
        res = nil
        expect {
          res = browser.post '/polls/0/votes', { voter: 'Miyoshi', candidate: 'INVALID' }
        }.not_to change { poll.votes.size }

        expect(res.status).to eq 400
      end
    end
  end
end
