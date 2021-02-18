require_relative '../lib/timelimit'
require 'date'

# FIXME 時間によってテストが失敗する
RSpec.describe TimeLimit do
  it 'time and date passed' do
    limit = TimeLimit.new("2022-11-12", "12:00")
    expect(limit.time).to eq Time.parse("2022-11-12 12:00:00 +0900")
  end
  it 'time passed' do
    limit = TimeLimit.new("", "23:59")
    today = Time.now
    expect(limit.time).to eq Time.parse("#{today.year}-#{today.month}-#{today.day} 23:59:00 +0900")
  end
  it 'date passed' do
    limit = TimeLimit.new("2022-11-12", "")
    expect(limit.time).to eq Time.parse("2022-11-12 23:59:59 +0900")
  end
  it 'disabled' do
    limit = TimeLimit.new("", "")
    expect(limit.time).to eq nil
  end
end
