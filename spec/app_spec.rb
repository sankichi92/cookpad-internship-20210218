require 'sinatra/test_helpers'
require_relative '../app'

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

  xdescribe 'GET /polls/:id' do
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

  xdescribe 'POST /polls/:id/votes' do
    let(:poll) { Poll.new('Example Poll', ['Alice', 'Bob']) }

    before do
      $polls = [poll]
    end

    context 'with valid id and params' do
      it 'adds a vote and redirects to /polls/:id' do
        expect {
          post '/polls/0/votes', { voter: 'Miyoshi', candidate: 'Alice' }
        }.to change { poll.votes.size }.by(1)

        expect(last_response.status).to eq 303
        expect(last_response.headers['Location']).to match %r{/polls/0$}
      end
    end

    context 'with invalid id' do
      it 'responds 404 Not Found' do
        expect {
          post '/polls/1/votes', { voter: 'Miyoshi', candidate: 'Alice' }
        }.not_to change { poll.votes.size }

        expect(last_response.status).to eq 404
      end
    end

    context 'with invalid params' do
      it 'responds 400 Bad Request' do
        expect {
          post '/polls/0/votes', { voter: 'Miyoshi', candidate: 'INVALID' }
        }.not_to change { poll.votes.size }

        expect(last_response.status).to eq 400
      end
    end
  end
end
