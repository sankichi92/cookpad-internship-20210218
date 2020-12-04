require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'lib/poll'
require_relative 'lib/vote'

$polls = [
  Poll.new('好きな料理', ['肉じゃが', 'しょうが焼き', 'から揚げ']),
  Poll.new('人気投票', ['おむすびけん', 'クックパッドたん']),
]

get '/' do
  erb :index, locals: { polls: $polls }
end

get '/polls/:id' do
  index = params['id'].to_i
  poll = $polls[index]
  halt 404, '投票が見つかりませんでした' if poll.nil?

  erb :poll, locals: { index: index, poll: poll }
end
