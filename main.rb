def log(msg)
  mutex = Mutex.new
  mutex.lock
  puts msg
  mutex.unlock
end

def assert(assertion, msg=nil)
  msg ||= 'Assertion failed'

  raise "\e[31m#{msg}\e[0m" unless assertion
end

def ni
  raise "Not implemented"
end

require_relative 'fragment_loader'
log 'Loading fragments'
FragmentLoader.load_fragments

log 'Done loading fragments'
log ''
log "======================================================="
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
begin










FragmentLoader.set_configuration(:os, :IOS)
Home.login
Home.open_menu

Home.titles.each do |title|
  Home.visit_title(title)
  Home::Planet.assert_title # SHOULD WE DO Planet.assert_title(Home) instead? Or Home.for(Planet).assert_title
  #Home.assert_title
end









rescue => e
  log "\e[31mTest failed! '#{e.message}'\e[0m"
  e.backtrace.first(4).each {|trace| log(trace)} if e && e.backtrace
  log("....")
  e.backtrace.last(6).first(4).each {|trace| log(trace)} if e && e.backtrace
else
  log "\e[32mTest succeeded!\e[0m"
end





log ''
log ''