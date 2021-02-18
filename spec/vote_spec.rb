require_relative '../lib/vote'

RSpec.describe Vote do
  it 'has a voter and a candidate' do
    vote = Vote.new('Miyoshi', 'Alice')

    expect(vote.voter).to eq 'Miyoshi'
    expect(vote.candidate).to eq 'Alice'
  end

  describe Vote do
    it 'if empty name passed' do
      expect { Vote.new('', 'Alice') }.to raise_error Vote::EmptyNameError
    end
  end
end
