require_relative '../lib/ranked_vote'
require_relative '../lib/borda_poll'
require 'date'

RSpec.describe BordaPoll do
  it 'has a title and candidates' do
    poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.new(2020, 2, 18, 14, 57, 00, 0.125))

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']
    expect(poll.closing).to eq DateTime.new(2020, 2, 18, 14, 57, 00, 0.125)
  end
  
  describe '#add_vote' do
    it 'saves the given vote' do
      poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
      vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

      poll.add_vote(vote)

      expect(poll.votes).to include vote
    end

    context 'with a vote that has an invalid candidate' do
      it 'raises InvalidCandidateError' do
        poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
        vote = RankedVote.new('Miyoshi', ['INVALID', 'Bob'])

        expect { poll.add_vote(vote) }.to raise_error BordaPoll::InvalidCandidateError
      end

      it 'raises InvalidCandidateError' do
        poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
        vote = RankedVote.new('Miyoshi', ['Bob', 'Bob'])

        expect { poll.add_vote(vote) }.to raise_error BordaPoll::InvalidCandidateError
      end
    end

    context 'with a vote that has an invalid voter' do
      it 'raises MultipleVoteError' do
        poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
        vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

        poll.add_vote(vote)
        expect { poll.add_vote(vote) }.to raise_error BordaPoll::MultipleVoteError
      end
    end

    context 'with a vote that is overdue' do
      it 'raises OverdueVoteError' do
        poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now - 10)
        vote = RankedVote.new('Miyoshi', ['Alice', 'Bob'])

        expect { poll.add_vote(vote) }.to raise_error BordaPoll::OverdueVoteError
      end
    end
  end

  describe '#count_votes' do
    it 'count the votes and returns the result as a hash' do
      poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
      poll.add_vote(RankedVote.new('Carol', ['Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Dave', ['Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Ellen', ['Bob', 'Alice']))

      result = poll.count_votes
       
      expect(result['Alice']).to eq 5
      expect(result['Bob']).to eq 4
    end

    it 'count the votes and returns the result as a hash' do
      poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now + 10)
      poll.add_vote(RankedVote.new('Carol', ['Bob', 'Alice']))
      poll.add_vote(RankedVote.new('Dave', ['Bob', 'Alice']))
      poll.add_vote(RankedVote.new('Ellen', ['Bob', 'Alice']))

      result = poll.count_votes
       
      expect(result['Alice']).to eq 3
      expect(result['Bob']).to eq 6
    end

    it 'count the votes and returns the result as a hash' do 
      poll = BordaPoll.new('Awesome Poll', ['Alice', 'Bob', 'Carol'], DateTime.now + 10)
      poll.add_vote(RankedVote.new('Dave', ['Alice', 'Bob', 'Carol']))
      poll.add_vote(RankedVote.new('Ellen', ['Carol', 'Alice', 'Bob']))
      poll.add_vote(RankedVote.new('Frank', ['Carol', 'Alice', 'Bob']))

      result = poll.count_votes
       
      expect(result['Alice']).to eq 7
      expect(result['Bob']).to eq 4
      expect(result['Carol']).to eq 7
    end
  end
end
