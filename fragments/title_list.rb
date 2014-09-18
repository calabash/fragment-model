module TitleList
  uses :Planet # Dependent fragment

  def self.titles
    ['Sun', 'Moon', 'Earth']
  end

  def self.visit_title(title)
    set_state!(title: title)
    log "Touching title #{title}"
    log "I am now on planet page"
    #Planet.set_state!('last_visited_title' => title) # this is bad
  end

  def self.last_visited_title
    state(:title, 'No title has been visited yet!')
  end
end

#TODO: Add the idea of SNAPSHOT! Which caches this page
# Use snapsonts and make them auto snapshots
# The dependent page should then default to the leading pages snapshot
# all methods can snapshot and cache their value

#parent
=begin
snapshot
def current_title
  query("* id:'title'")
end
=end

#child
=begin
def assert_title
  get_title == current_title
=end
