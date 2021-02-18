require 'sinatra'
require 'sinatra/reloader'
require_relative 'lib/poll'
require_relative 'lib/vote'

$polls = [
  Poll.new('好きな料理', ['肉じゃが', '生姜焼き', 'からあげ']),
  Poll.new('人気投票', ['おむすびけん', 'クックパッドたん']),
]

$default_draft = Poll.new('タイトル', [])

$draft = Poll.new('タイトル', [])

get '/' do
  '投票一覧'
  erb :index, locals: { polls: $polls, draft: $draft }
end

post '/' do
  '投票一覧'
  title = params["title"]
  cand_regex = /^cand\d+$/
  candidates = params.select {|key, value| cand_regex.match(key)}.map { |_, val| val}
  $polls << Poll.new(title, candidates)
  erb :index, locals: { polls: $polls, draft: $default_draft }
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
  erb :result, locals: { index: index, poll: poll }
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


