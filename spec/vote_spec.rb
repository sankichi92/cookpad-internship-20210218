require_relative '../lib/vote'

RSpec.describe Vote do
  it 'has a voter and candidates' do
    vote = Vote.new('Miyoshi', 'Alice')

    expect(vote.voter).to eq 'Miyoshi'
    expect(vote.candidate).to eq 'Alice'
  end

  describe '#add_vote' do
    it 'saves the given vote' do
      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])
      vote = Vote.new('Miyoshi', 'Alcie')

      poll.add_vote(vote)

      expect(poll.votes).to eq [vote]
    end
  end
end
