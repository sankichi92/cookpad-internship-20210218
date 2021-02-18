require 'sinatra'
require 'sinatra/reloader'
require_relative 'lib/poll'
require_relative 'lib/vote'

$polls = [
  Poll.new('好きな料理', ['肉じゃが', '生姜焼き', 'からあげ']),
  Poll.new('人気投票', ['おむすびけん', 'クックパッドたん']),
]

get '/' do
  '投票一覧'
  erb :index, locals: { polls: $polls }
end

get '/polls/:id' do
  index = params['id'].to_i
  poll = $polls[index]
  halt 404, '投票が見つかりませんでした' if poll.nil?
  erb :poll, locals: { index: index, poll: poll }
end

get '/polls/:id/result' do
  index = params['id'].to_i
  poll = $polls[index]
  halt 404, '投票が見つかりませんでした' if poll.nil?
  erb :result, locals: { index: index, title: poll.title, result: poll.count_votes }
end

post '/polls/:id/votes' do
  index = params['id'].to_i
  poll = $polls[index]
  halt 404, '投票が見つかりませんでした' if poll.nil?
  voter = params[:voter]
  candidate = params[:candidate]

  begin
    poll.add_vote(Vote.new(voter, candidate))
  rescue Poll::InvalidCandidateError
    halt 400, '無効な投票先です'
    erb :poll, locals: { index: index, poll: poll }
  rescue Poll::VoteTimeLimitExceededError
    halt 400, '投票期限を過ぎています'
    erb :poll, locals: { index: index, poll: poll }
  rescue Poll::DuplicatedVoteError
    halt 400, '二重投票です'
    erb :poll, locals: { index: index, poll: poll }
  rescue Vote::EmptyNameError
    halt 400, '名前が無記名です'
    erb :poll, locals: { index: index, poll: poll }
  end

  redirect to('/polls/' + index.to_s), 303
end


