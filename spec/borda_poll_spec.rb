require_relative '../lib/borda_poll'

expired_date = Date.new(1970, 1, 1)
valid_date = Date.today + 2

RSpec.describe BordaPoll do
  it 'has a title and candidates' do
    poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'])

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']
  end

  it 'may have an expiration date' do
    poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], valid_date)

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']
    expect(poll.expiresAt).to eq valid_date
  end

  describe '#add_vote' do
    it 'saves the given vote' do
      poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'])
      vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

      poll.add_vote(vote)

      expect(poll.votes).to eq [vote]
    end

    context 'with a vote that has an invalid candidate' do
      it 'raises InvalidCandidateError' do
        poll1 = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'])
        vote1 = RankedVote.new('Miyoshi', ['INVALID'])

        expect { poll1.add_vote(vote1) }.to raise_error BordaPoll::InvalidCandidateError

        poll2 = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'])
        vote2 = RankedVote.new('Miyoshi', ['Alice'])

        expect { poll2.add_vote(vote2) }.to raise_error BordaPoll::InvalidCandidateError
      end
    end

    context 'with a vote whose voter is duplicated' do
      it 'raises DuplicatedVoterError' do
        poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'])
        vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])
        dup_vote = RankedVote.new('Miyoshi', ['Bob', 'Alice'])

        poll.add_vote(vote)

        expect { poll.add_vote(dup_vote) }.to raise_error BordaPoll::DuplicatedVoterError
      end
    end

    context 'to an expired poll' do
      it 'raises VoteToExpiredPollError' do
        poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], expired_date)
        vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

        expect { poll.add_vote(vote) }.to raise_error BordaPoll::VoteToExpiredPollError
      end
    end
  end

  describe '#count_votes' do
    it 'counts the votes and returns the result as a hash' do
      poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'])
      poll.add_vote(RankedVote.new('Carol', ['Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Dave', ['Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Ellen', ['Bob', 'Alice']))

      result = poll.count_votes

      expect(result['Alice']).to eq 5
      expect(result['Bob']).to eq 4

      poll2 = BordaPoll.new('Great Poll', ['Alice', 'Bob'])
      poll2.add_vote(RankedVote.new('Carol', ['Bob', 'Alice']))
      poll2.add_vote(RankedVote.new('Dave', ['Bob', 'Alice']))

      result2 = poll2.count_votes

      expect(result2['Alice']).to eq 2
      expect(result2['Bob']).to eq 4
    end
  end
end