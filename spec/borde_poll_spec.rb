require_relative '../lib/ranked_vote'
require_relative '../lib/borda_poll'

RSpec.describe 'BordaPoll' do
  it 'has a title and candidates' do
    poll = BordaPoll.new('Great Poll', ['Alice', 'Bob'])

    expect(poll.title).to eq 'Great Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']
  end

  it 'has a title and sorted candidates' do
    poll = BordaPoll.new('Awesome Poll', ['Charry', 'Alice'])

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Charry']
  end

  describe '#add_vote' do
    it 'saves the given vote' do
      vote1 = RankedVote.new("Alpha", %w[Alice Bob Carol])
      vote2 = RankedVote.new("Beta", %w[Carol Alice Bob])
      vote3 = RankedVote.new("Gamma", %w[Carol Alice Bob])
      poll = BordaPoll.new('Awesome Poll', %w[Alice Bob Carol])
      poll.add_vote(vote1)
      poll.add_vote(vote2)
      poll.add_vote(vote3)
      expect(poll.votes).to eq [vote1, vote2, vote3]
    end

    context 'with a vote that has an invalid candidate' do
      it 'raises InvalidCandidateError' do
        poll = BordaPoll.new('Awesome Poll', %w[Alice Bob])
        vote = RankedVote.new('Nakano', ['INVALID'])

        expect { poll.add_vote(vote) }.to raise_error MultiPollValidator::InvalidCandidateError
      end
    end

    context 'with a vote that has duplicated candidates' do
      it 'raises InvalidCandidateError' do
        poll = BordaPoll.new('Awesome Poll', %w[Alice Bob])
        vote = RankedVote.new('Nakano', ['Alice', 'Alice'])

        expect { poll.add_vote(vote) }.to raise_error MultiPollValidator::InvalidCandidateError
      end
    end

    context 'with a vote that doesn\'t have enough candidates' do
      it 'raises InvalidCandidateError' do
        poll = BordaPoll.new('Awesome Poll', %w[Alice Bob])
        vote = RankedVote.new('Nakano', ['Alice'])

        expect { poll.add_vote(vote) }.to raise_error MultiPollValidator::InvalidCandidateError
      end
    end

    it 'over deadline' do
      poll = BordaPoll.new('Awesome BordaPoll', ['Alice', 'Bob'], TimeLimit.new("1999-11-12", ""))
      vote = RankedVote.new('Nakano', %w[Alice Bob])
      expect { poll.add_vote(vote) }.to raise_error MultiPollValidator::VoteTimeLimitExceededError
      expect(poll.votes).to eq []
    end

    it 'before deadline' do
      poll = BordaPoll.new('Awesome BordaPoll', ['Alice', 'Bob'], TimeLimit.new("2222-12-31", ""))
      vote = RankedVote.new('Nakano', %w[Alice Bob])
      poll.add_vote(vote)
      expect(poll.votes).to eq [vote]
    end
  end

  describe "#count_votes" do
    it 'count the votes and return the result as a hash' do
      vote1 = RankedVote.new("Alpha", %w[Alice Bob Carol])
      vote2 = RankedVote.new("Beta", %w[Carol Alice Bob])
      vote3 = RankedVote.new("Gamma", %w[Carol Alice Bob])
      poll = BordaPoll.new('Awesome Poll', %w[Alice Bob Carol])
      poll.add_vote(vote1)
      poll.add_vote(vote2)
      poll.add_vote(vote3)
      result = poll.count_votes
      expect(result['Alice']).to eq 7
      expect(result['Bob']).to eq 4
      expect(result['Carol']).to eq 7
    end
    it 'raise error when same actor votes again' do
      poll = BordaPoll.new('Awesome Poll', %w[Alice Bob])
      poll.add_vote(RankedVote.new('Dave', %w[Bob Alice]))
      expect { poll.add_vote(RankedVote.new('Dave', %w[Alice Bob])) }.to raise_error MultiPollValidator::DuplicatedVoteError
    end
  end
end
