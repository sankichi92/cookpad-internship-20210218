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
end
