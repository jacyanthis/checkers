require 'io/console'

def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return input
end

# oringal case statement from:
# http://www.alecjacobson.com/weblog/?p=75
def show_single_key
  c = read_char

  case c
  when "\e[A"
    :up
  when "\e[B"
    :down
  when "\e[C"
    :right
  when "\e[D"
    :left
  when "\r"
    :return
  when /^.$/
    p c.inspect.to_sym
    c.inspect.to_sym
  when "\u0003"
    puts "CONTROL-C"
    exit 0
  else
    puts "SOMETHING ELSE: #{c.inspect}"
  end
end
