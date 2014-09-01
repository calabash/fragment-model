module SideMenu
  # right now we don't trigger extensions based on method calls. TODO
  # add: configuration :tablet: 'method_a', where method_a will trigger configuration changes
  # We can also add methods to determine what configurations we need like
  # find_out_if_tablet
  configuration :os

  def self.open_menu
    log "Panning right"
    log "Waiting for element exists #{menu_frame}"
  end
end