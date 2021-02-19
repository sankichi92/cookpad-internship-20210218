require_relative '../lib/ranked_vote'
require_relative '../lib/condorcet_poll'
require 'date'

RSpec.describe CondorcetPoll do
  it 'has a title and candidates' do
    poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.new(2020, 2, 18, 14, 57, 00, 0.125))

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']
    expect(poll.closing).to eq DateTime.new(2020, 2, 18, 14, 57, 00, 0.125)
  end

  describe '#add_vote' do
    it 'saves the given vote' do
      poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
      vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

      poll.add_vote(vote)

      expect(poll.votes).to include vote
    end

    context 'with a vote that has an invalid candidate' do
      it 'raises InvalidCandidateError' do
        poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
        vote = RankedVote.new('Miyoshi', ['INVALID', 'Bob'])

        expect { poll.add_vote(vote) }.to raise_error CondorcetPoll::InvalidCandidateError
      end

      it 'raises InvalidCandidateError' do
        poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
        vote = RankedVote.new('Miyoshi', ['Bob', 'Bob'])

        expect { poll.add_vote(vote) }.to raise_error CondorcetPoll::InvalidCandidateError
      end
    end

    context 'with a vote that has an invalid voter' do
      it 'raises MultipleVoteError' do
        poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
        vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

        poll.add_vote(vote)
        expect { poll.add_vote(vote) }.to raise_error CondorcetPoll::MultipleVoteError
      end
    end

    context 'with a vote that is overdue' do
      it 'raises OverdueVoteError' do
        poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now - 10)
        vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

        expect { poll.add_vote(vote) }.to raise_error CondorcetPoll::OverdueVoteError
      end
    end
  end

  describe '#count_votes' do
    it 'count the votes and returns the result as a winner array' do
      poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
      poll.add_vote(RankedVote.new('Carol', ['Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Dave', ['Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Ellen', ['Bob', 'Alice']))

      expect(poll.count_votes).to eq ['Alice']
    end

    it 'count the votes and returns the result as a winner array' do
      poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
      poll.add_vote(RankedVote.new('Carol', ['Bob', 'Alice']))
      poll.add_vote(RankedVote.new('Dave', ['Bob', 'Alice']))
      poll.add_vote(RankedVote.new('Ellen', ['Bob', 'Alice']))

      expect(poll.count_votes).to eq ['Bob']
    end

    it 'count the votes and returns the result as a winner array' do
      poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob', 'Carol'], DateTime.now + 10)
      poll.add_vote(RankedVote.new('Dave', ['Alice', 'Bob', 'Carol']))
      poll.add_vote(RankedVote.new('Ellen', ['Carol', 'Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Frank', ['Carol', 'Alice', 'Bob']))

      expect(poll.count_votes).to eq ['Carol']
    end

    it 'count the votes and returns the result as a winner array' do
      poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob', 'Carol'], DateTime.now + 10)
      poll.add_vote(RankedVote.new('Dave', ['Alice', 'Bob', 'Carol']))
      poll.add_vote(RankedVote.new('Ellen', ['Carol', 'Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Frank', ['Bob', 'Carol', 'Alice']))

      expect(poll.count_votes).to include 'Alice'
      expect(poll.count_votes).to include 'Bob'
      expect(poll.count_votes).to include 'Carol'
      expect(poll.count_votes.length).to eq 3
    end

    it 'count the votes and returns the result as a winner array' do
      poll = CondorcetPoll.new('Awesome Poll', ['Alice', 'Bob', 'Carol', 'Dave', 'Ellen', 'Flank'], DateTime.now + 10)
      poll.add_vote(RankedVote.new('George', ['Alice', 'Bob', 'Carol', 'Dave', 'Ellen', 'Flank']))
      poll.add_vote(RankedVote.new('Henry', ['Flank', 'Bob', 'Carol', 'Dave', 'Alice','Ellen']))
      poll.add_vote(RankedVote.new('Ivan', ['Flank', 'Alice', 'Carol', 'Bob', 'Dave', 'Ellen']))

      expect(poll.count_votes).to include 'Flank'
      expect(poll.count_votes.length).to eq 1
    end
  end
end
