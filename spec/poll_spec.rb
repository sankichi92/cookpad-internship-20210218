require_relative '../lib/poll.rb'

RSpec.describe Poll do
  it 'has a title and candidates' do
    poll = Poll.new('Great Poll', ['Alice', 'Bob'])

    expect(poll.title).to eq 'Great Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']

    poll = Poll.new('Awesome Poll', ['Alice', 'Charry'])

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Charry']
  end

  describe "#add_vote" do
    it 'saves the given vote' do
      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'])
      vote = Vote.new('Nakano', 'Alice')
      poll.add_vote(vote)
      expect(poll.votes).to eq [vote]
    end

    it 'over deadline' do
      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'], 2)
      vote = Vote.new('Nakano', 'Alice', 3)
      poll.add_vote(vote)
      expect(poll.votes).to eq []
    end

    it 'before deadline' do
      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'], 3)
      vote = Vote.new('Nakano', 'Alice', 2)
      poll.add_vote(vote)
      expect(poll.votes).to eq [vote]
    end
  end
end
