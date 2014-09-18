def log(msg)
  puts msg
end

def ni
  raise "Not implemented"
end

require_relative 'fragment_loader'
log 'Loading fragments'
FragmentLoader.load_fragments

log 'Done loading fragments'
log ''
puts "======================================================="
log ''

$t = []
=begin
set_trace_func proc { |event, file, line, id, binding, classname|
  if file.include?('fragments')
    s = "#{classname.to_s.split("::").last}.#{id}"

    unless $t.include?(s)
      puts "\e[37m#{s}\e[0m"
      $t << s
    end
  end
}
=end












FragmentLoader.set_configuration(:os, :IOS)
Home.login
Home.open_menu

Home.titles.each do |title|
  Home.visit_title(title)
  Home.Planet.assert_title
  #Home.assert_title
end















log ''
log ''