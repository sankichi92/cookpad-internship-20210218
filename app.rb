require 'sinatra'
require 'sinatra/cookies'
require 'sinatra/reloader'
require 'sinatra/json'
require 'json'
require_relative 'lib/poll'
require_relative 'lib/vote'
require_relative 'lib/timelimit'
require 'time'

$polls = [
  Poll.new('好きな料理', ['肉じゃが', '生姜焼き', 'からあげ']),
  Poll.new('人気投票', ['おむすびけん', 'クックパッドたん']),
]

$users = {
}

$sessions = {}

$default_draft = Poll.new('タイトル', [])

$draft = Poll.new('タイトル', [])

get '/' do
  '投票一覧'
  if cookies[:username] == "" || cookies[:username].nil?
    logined = false
  else
    logined = true
  end
  erb :index, locals: { polls: $polls, draft: $draft, logined: logined }
end

get '/login' do
  erb :login
end

get '/signup' do
  erb :signup
end

get '/logout' do
  cookies[:username] = ""
  redirect to('/'), 303
end

post '/' do
  '投票一覧'
  title = params["title"]
  cand_regex = /^cand\d+$/
  candidates = params.select { |key, value| cand_regex.match(key) }.map { |_, val| val }
  halt 400, '候補は2つ以上必要です' if candidates.size < 2
  timelimit = TimeLimit.new(params["date"], params["time"])
  if cookies[:username] == "" || cookies[:username].nil?
    logined = false
  else
    logined = true
  end
  $polls << Poll.new(title, candidates, timelimit)
  p params
  erb :index, locals: { polls: $polls, draft: $default_draft, logined: logined }
end

get '/polls/:id' do
  index = params['id'].to_i
  poll = $polls[index]
  halt 404, '投票が見つかりませんでした' if poll.nil?
  if cookies[:username] == "" || cookies[:username].nil?
    state = 'guest'
  elsif poll.voted?(cookies[:username])
    state = 'polled'
  else
    state = 'yet'
  end
  erb :poll, locals: { index: index, poll: poll, state: state }
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
  voter = cookies[:username]

  if poll.voted?(voter)
    poll.undo(voter)
  else
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
  end

  redirect to('/polls/' + index.to_s), 303
end
