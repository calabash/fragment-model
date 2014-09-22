module Shirt
  def self.select_shirt_size(size)
    touch(shirt_shirt_element)
    touch("* text:'#{size}'")
  end

  def self.select_shirt_color(color)
    touch(shirt_color_element)
    touch("* text:'#{color}'")
  end

  def self.shirt_shirt_element
    "android.widget.Spinner id:'productSize'"
  end

  def self.shirt_color_element
    "android.widget.Spinner id:'productColor'"
  end
end