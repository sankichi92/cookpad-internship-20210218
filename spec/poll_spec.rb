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

    context 'with a vote that has an invalid candidate' do
      it 'raises InvalidCandidateError' do
        poll = Poll.new('Awesome Poll', %w[Alice Bob])
        vote = Vote.new('Nakano', 'INVALID')

        expect { poll.add_vote(vote) }.to raise_error Poll::InvalidCandidateError
      end
    end

    it 'over deadline' do
      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'], TimeLimit.new("1999-11-12", ""))
      vote = Vote.new('Nakano', 'Alice')
      expect { poll.add_vote(vote) }.to raise_error Poll::VoteTimeLimitExceededError
      expect(poll.votes).to eq []
    end

    it 'before deadline' do
      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'], TimeLimit.new("2222-12-31", ""))
      vote = Vote.new('Nakano', 'Alice')
      poll.add_vote(vote)
      expect(poll.votes).to eq [vote]
    end
  end

  describe '#count_votes' do
    it 'count the votes and return the result as a hash' do
      poll = Poll.new('Awesome Poll', %w[Alice Bob])
      poll.add_vote(Vote.new('Carol', 'Alice'))
      poll.add_vote(Vote.new('Dave', 'Alice'))
      poll.add_vote(Vote.new('Ellen', 'Bob'))

      result = poll.count_votes

      expect(result['Alice']).to eq 2
      expect(result['Bob']).to eq 1

      poll = Poll.new('Awesome Poll', %w[Alice Bob])
      poll.add_vote(Vote.new('Dave', 'Bob'))
      poll.add_vote(Vote.new('Ellen', 'Bob'))

      result = poll.count_votes

      expect(result['Alice']).to eq 0
      expect(result['Bob']).to eq 2
    end

    it 'raise error when same actor votes again' do
      poll = Poll.new('Awesome Poll', %w[Alice Bob])
      poll.add_vote(Vote.new('Dave', 'Bob'))
      expect { poll.add_vote(Vote.new('Dave', 'Alice')) }.to raise_error Poll::DuplicatedVoteError
    end
  end
end
