module Login
  uses :Credentials

  def self.login
    enter_username
  end

  def self.enter_username
    log "Entering '#{username}' into \"#{username_field}\""
    log "Entering '#{password}' into \"#{password_field}\""
    log "Tapping \"#{login_button}\""
  end

  def self.username_field
    "* id:'username'"
  end

  def self.password_field
    "* id:'password'"
  end

  def self.login_button
    "* id:'login'"
  end
end