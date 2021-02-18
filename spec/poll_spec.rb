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
end
