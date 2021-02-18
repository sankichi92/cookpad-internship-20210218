require_relative '../lib/vote'
require_relative '../lib/poll'
require 'date'

RSpec.describe Poll do
  it 'has a title and candidates' do
    poll = Poll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.new(2020, 2, 18, 14, 57, 00, 0.125))

    expect(poll.title).to eq 'Awesome Poll'
    expect(poll.candidates).to eq ['Alice', 'Bob']
    expect(poll.closing).to eq DateTime.new(2020, 2, 18, 14, 57, 00, 0.125)
  end
  
  describe '#add_vote' do
    it 'saves the given vote' do
      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now)
      vote = Vote.new('Miyoshi', 'Alice')

      poll.add_vote(vote)

      expect(poll.votes).to include vote
    end

    context 'with a vote that has an invalid candidate' do
      it 'raises InvalidCandidateError' do
        poll = Poll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now)
        vote = Vote.new('Miyoshi', 'INVALID')

        expect { poll.add_vote(vote) }.to raise_error Poll::InvalidCandidateError
      end
    end

    context 'with a vote that has an invalid voter' do
      it 'raises MultipleVoteError' do
        poll = Poll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now)
        vote = Vote.new('Miyoshi', 'Alice')

        poll.add_vote(vote)
        expect { poll.add_vote(vote) }.to raise_error Poll::MultipleVoteError
      end
    end
  end


  describe '#count_votes' do
    it 'count the votes and returns the result as a hash' do
      poll = Poll.new('Awesome Poll', ['Alice', 'Bob'], DateTime.now)
      poll.add_vote(Vote.new('Carol', 'Alice'))
      poll.add_vote(Vote.new('Dave', 'Alice'))
      poll.add_vote(Vote.new('Ellen', 'Bob'))

      result = poll.count_votes
       
      expect(result['Alice']).to eq 2
      expect(result['Bob']).to eq 1
    end
  end
end
