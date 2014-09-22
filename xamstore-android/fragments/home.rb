module Home
  uses :Shirts

  def self.await
    log "Awaiting"
    Shirts.await
    log "Awaiting"
  end
end