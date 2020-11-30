RSpec.describe 'DevEnv' do
  specify 'Ruby version is greater than or equal to 2.5' do
    expect(RUBY_VERSION).to be >= '2.5.0'
  end
end
