# Leading pages: Home

module Planet
  def self.read_title
    "Sun"
  end

  def self.assert_title
    log 'Asserting title... '

    assert(read_title == last_visited_title, "Read title '#{read_title}' should be last visited title '#{last_visited_title}'")
  end

  # Let parent handle this
  #def self.last_visited_title
    #state('last_visited_title')
  #end
end

# YOU CANT OPEN IF YOU DON*T CLOSE