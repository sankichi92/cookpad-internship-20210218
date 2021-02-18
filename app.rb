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

post '/polls/:id/votes' do
  index = params['id'].to_i
  poll = $polls[index]
  halt 404, '投票が見つかりませんでした' if poll.nil?
  voter = params[:voter]
  candidate = params[:candidate]

  begin
    poll.add_vote(Vote.new(voter, candidate))
  rescue => e
    halt 400, '無効な投票先です'
  end

  redirect to('/polls/' + index.to_s), 303
end

