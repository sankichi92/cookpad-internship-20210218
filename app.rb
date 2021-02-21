require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'json'
require_relative 'lib/poll'
require_relative 'lib/vote'
require_relative 'lib/timelimit'
require_relative 'lib/session_manager'
require 'time'

enable :sessions

$polls = [
  Poll.new('好きな料理', ['肉じゃが', '生姜焼き', 'からあげ']),
  Poll.new('人気投票', ['おむすびけん', 'クックパッドたん']),
]

$users = {
}

$sessions = SessionManager.new()

get '/' do
  '投票一覧'
  erb :index, locals: { polls: $polls, sess: $sessions.request_info(session[:session_id]) }
end

get '/login' do
  erb :login
end

get '/logout' do
  $sessions.logout(session[:session_id])
  redirect to('/'), 303
end

post '/login', provides: :json do
  param = JSON.parse request.body.read
  if param["user"].nil?
    begin
      json $sessions.confirm_login(session[:session_id], param["token"], Poll.new("投票", []))
    rescue SessionManager::WrongPassword
      halt 403, json({ result: false })
    rescue SessionManager::UnknownSession
      halt 403, json({ result: false })
    end
  else
    begin
      json $sessions.start_login(session[:session_id], param["user"])
    rescue Authenticator::UserNotFound
      halt 403, json({ result: false })
    end
  end
end

post '/signup', provides: :json do
  params = JSON.parse request.body.read
  begin
    $sessions.signup(session[:session_id], params['user'], params['salt'], params['pass'], Poll.new('タイトル', []))
    json ({ result: true })
  rescue Authenticator::AlreadyRegistered
    halt 400, json({ result: false, msg: '既に登録されています' })
  end
end

get '/signup' do
  erb :signup
end

post '/' do
  '投票一覧'
  title = params["title"]
  cand_regex = /^cand\d+$/
  candidates = params.select { |key, value| cand_regex.match(key) }.map { |_, val| val }
  halt 400, '候補は2つ以上必要です' if candidates.size < 2
  timelimit = TimeLimit.new(params["date"], params["time"])
  if session[:username] == "" || session[:username].nil?
    logined = false
  else
    logined = true
  end
  $polls << Poll.new(title, candidates, timelimit)
  erb :index, locals: { polls: $polls, sess: $sessions.request_info(session[:session_id]) }
end

get '/polls/:id' do
  index = params['id'].to_i
  poll = $polls[index]
  halt 404, '投票が見つかりませんでした' if poll.nil?
  info = $sessions.request_info(session[:session_id])
  if info[:user].nil?
    state = 'guest'
  elsif poll.voted?(info[:user])
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
  info = $sessions.request_info(session[:session_id])
  halt 403, 'ログインが必要です' unless info[:login]
  voter = info[:user]

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
