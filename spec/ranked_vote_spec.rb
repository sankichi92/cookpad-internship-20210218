require_relative '../lib/ranked_vote'

RSpec.describe 'RankedVote' do
  it 'has a voter and a candidate' do
    vote = RankedVote.new('Nakano', %w[Alice, Bob])

    expect(vote.voter).to eq 'Nakano'
    expect(vote.candidates).to eq %w[Alice, Bob]
  end

  describe Vote do
    it 'if empty name passed' do
      expect { RankedVote.new('', []) }.to raise_error RankedVote::EmptyNameError
    end
  end
end
