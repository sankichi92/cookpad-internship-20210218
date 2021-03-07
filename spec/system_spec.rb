require 'sinatra/test_helpers'
require_relative 'spec_helper'
require 'sinatra'

RSpec.describe 'System' do
  include Sinatra::TestHelpers

  before do
    set_app Sinatra::Application
    $polls = []
  end

  it 'GET /', js: true do
    visit 'localhost:4567/'
  end
end
