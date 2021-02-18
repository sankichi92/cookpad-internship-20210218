class Poll
  attr_reader :title, :candidates

  def initialize(title, candidates)
    @title = title
    @candidates = candidates
  end
end
