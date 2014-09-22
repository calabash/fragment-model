module Shirts
  uses :Shirt

  def self.await
    log "awaiting"
    #wait_for_element_exists("android.widget.TextView text:'Xamarin Store'")
    #wait_for_element_does_not_exist('android.widget.ProgressBar')
    log "done awaiting"
  end

  def self.select_shirt(type, size=nil, color=nil)
    log "Selecting shirt #{type}"
    if type == :male
      touch("all android.widget.ImageView id:'productImage' index:0")
      log "Touching male"
    elsif type == :female
      touch("all android.widget.ImageView id:'productImage' index:1")
    else
      raise "Invalid option #{type}"
    end

    select_shirt_size(size) if size != nil
    select_shirt_color(color) if color != nil
  end
end