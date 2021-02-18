require_relative '../lib/vote'

RSpec.describe Vote do
  it 'has a voter and a candidate' do
    vote = Vote.new('Miyoshi', 'Alice')

    expect(vote.voter).to eq 'Miyoshi'
    expect(vote.candidate).to eq 'Alice'
  end
end
