# Leading pages: Home

module Planet
  def self.read_title
    "Sun"
  end

  def self.assert_title
    log 'Asserting title'

    if read_title != last_visited_title
      log "\e[31mFailure! #{read_title} != #{last_visited_title}\e[0m"
    end
  end

  def self.last_visited_title
    state('last_visited_title')
  end
end

# YOU CANT OPEN IF YOU DON*T CLOSE