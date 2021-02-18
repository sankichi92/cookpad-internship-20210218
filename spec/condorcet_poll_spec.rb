require_relative '../lib/condorcet_poll'

expired_date = Date.new(1970, 1, 1)
valid_date = Date.today + 2

RSpec.describe CondorcetPoll do
  it 'has a title and candidates' do
    poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'])

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']
  end

  it 'may have an expiration date' do
    poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], valid_date)

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']
    expect(poll.expiresAt).to eq valid_date
  end

  describe '#add_vote' do
    it 'saves the given vote' do
      poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'])
      vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

      poll.add_vote(vote)

      expect(poll.votes).to eq [vote]
    end

    context 'with a vote that has an invalid candidate' do
      it 'raises InvalidCandidateError' do
        poll1 = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'])
        vote1 = RankedVote.new('Miyoshi', ['INVALID'])

        expect { poll1.add_vote(vote1) }.to raise_error CondorcetPoll::InvalidCandidateError

        poll2 = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'])
        vote2 = RankedVote.new('Miyoshi', ['Alice'])

        expect { poll2.add_vote(vote2) }.to raise_error CondorcetPoll::InvalidCandidateError
      end
    end

    context 'with a vote whose voter is duplicated' do
      it 'raises DuplicatedVoterError' do
        poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'])
        vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])
        dup_vote = RankedVote.new('Miyoshi', ['Bob', 'Alice'])

        poll.add_vote(vote)

        expect { poll.add_vote(dup_vote) }.to raise_error CondorcetPoll::DuplicatedVoterError
      end
    end

    context 'to an expired poll' do
      it 'raises VoteToExpiredPollError' do
        poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], expired_date)
        vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

        expect { poll.add_vote(vote) }.to raise_error CondorcetPoll::VoteToExpiredPollError
      end
    end
  end

  describe '#get_winner' do
    it 'returns the winner' do
      poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'])
      poll.add_vote(RankedVote.new('Carol', ['Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Dave', ['Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Ellen', ['Bob', 'Alice']))

      result = poll.get_winner

      expect(result).to eq 'Alice'

      poll2 = CondorcetPoll.new('Great Poll', ['Alice', 'Bob', 'Carol'])
      poll2.add_vote(RankedVote.new('Dave', ['Alice', 'Bob', 'Carol']))
      poll2.add_vote(RankedVote.new('Dave2', ['Carol', 'Alice', 'Bob']))
      poll2.add_vote(RankedVote.new('Dave3', ['Carol', 'Alice', 'Bob']))

      result2 = poll2.get_winner

      expect(result2).to eq 'Carol'
    end
  end
end