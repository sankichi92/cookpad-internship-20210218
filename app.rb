require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'lib/poll'
require_relative 'lib/vote'

get '/' do
  polls = [
    Poll.new('好きな料理', ['肉じゃが', 'しょうが焼き', 'から揚げ']),
    Poll.new('人気投票', ['おむすびけん', 'クックパッドたん']),
  ]
  erb :index, locals: { polls: polls }
end
