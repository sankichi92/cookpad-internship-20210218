require_relative 'lib/vote'
require_relative 'lib/poll'
require 'sinatra'

get '/' do
  erb :index, :locals => {:polls => $polls}
end

get '/polls/:id' do |id|
  poll = $polls[id.to_i]

  if poll == nil then
    halt 404, "the poll id is not found"
  end

  erb :poll, :locals => {:index => id.to_i, :poll => poll}
end

post '/polls/:id/votes' do |id|
  voter = params[:voter]
  candidate = params[:candidate]
  poll = $polls[id.to_i]

  if poll == nil then
    halt 404, "the poll id is not found"
  end

  vote = Vote.new(voter, candidate)
  begin
    poll.add_vote(vote)
    redirect "/polls/#{id}", 303
  rescue Poll::InvalidCandidateError => e
    halt 400, "invalid candidate"
  end
end
