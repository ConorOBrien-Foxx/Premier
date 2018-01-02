#!/usr/bin/ruby
require 'io/console'

def ord(c)
    c.unpack("U*")[0]
end

def chr(c)
    c.chr(Encoding::UTF_8) rescue c
end

def pause
    exit(3) if STDIN.getch == "\x03"
    nil
end

def cls
    Gem.win_platform? ? (system "cls") : (system "clear")
end

class TrueClass;  def to_i; 1; end; end
class FalseClass; def to_i; 0; end; end

class String
    def -@
        self.reverse
    end
end

$vars = {
    'U' => 10,
    'V' => 100,
    'W' => 1000,
    'X' => 16,
    'Y' => 64,
    'Z' => 128,
}

class PremState
    def initialize(program, data)
        @data = data
        @program = program
        @stack = []
        @i = 0
        # iteration options
        @j = 0
        @build = ""
        @building = false
        @debug_iter = 1
        @implicit = true
    end
    
    def interp(val, str)
        temp_stack = @stack
        @stack = []
        str.chars.each { |op|
            @stack << val
            exec_op(op)
        }
        res = @stack.join
        @stack = temp_stack
        res
    end
    
    def exec_op(op)
        if @building
            @j += 1
            if op == @building
                build_char = @building
                @building = nil
                if build_char == '"'
                    @stack.push @build
                elsif build_char == '|'
                    @stack.push interp @stack.pop, @build
                else
                    STDERR.puts "No building op #{build_char.inspect}"
                    exit
                end
                @build = ""
                return :next
            else
                @build += op
                return :next
            end
        end
        
        case op
            when /^\d+$/
                @stack.push op.to_i
            when /^'/
                @stack.push op[1..-1]
            when /^`/
                @stack.push ord op[1..-1]
            when '"', '|'
                @building = op
            
            # uppercase
            when "A"
                @data += @stack.pop
            when "C"
                @stack.clear
            when "D"
                cls
                STDERR.puts "|Debug #{@i}##{@debug_it}"
                STDERR.puts "|  Data     | " + @data
                STDERR.puts "|           | " + " " * @i + "^"
                STDERR.puts "|  Program  | " + @program
                STDERR.puts "|           | " + " " * @j + "^"
                STDERR.puts "|  i        | #{@i}"
                STDERR.puts "|  stack    | #{@stack}"
                STDERR.puts "|  data     | #{@data.inspect}"
                STDERR.puts "|  current  | #{@c.inspect}"
                @debug_it += 1
                pause
            when "G"
                @data << STDIN.gets
            when "I"
                @implicit = false
            when "L"
                str, n = @stack.pop(2)
                @stack.push str[n..-1]
            when "N"
                @stack.push nil
            when "P"
                @stack.push @program
            when "Q"
                @stack.push @data
            when "S"
                @data << STDIN.read
            when "T"
                ent = @stack.pop
                @program = ent + @program
                @j += ent.size
                
            when 'U'..'Z'
                @stack.push $vars[op]
            
            # lowercase
            when "a"
                @program += @stack.pop
            when "b"
                n, b = @stack.pop(2)
                @stack.concat @stack.pop(n).rotate(b)
            when "c"
                @stack.push chr @stack.pop
            when "d"
                n = @stack.pop
                @stack.concat @stack[-n..-1]
            when "e"
                exit @stack.pop || -1
            # drop first N characters
            # when "f"
                # n = @stack.pop
                # @stack.push 
            when "i"
                @stack.push i
            when "l"
                @stack.push @stack.pop.size
            when "n"
                print @stack.pop
            when "o"
                @stack.push ord @stack.pop
            when "p"
                $><< ("" << @stack.pop)
            when "s"
                @stack.push @stack.pop.next
            when "v"
                @program += @stack.map { |e| chr e } .join
            
            # symbols
            when ";"
                pause
            when "_"
                @stack.push -@stack.pop
            when "#"
                @program = @stack.pop
                return :break
            when "%","+","-","*","/"
                a, b = @stack.pop(2)
                val = a.send op, b rescue 0
                @stack.push val
            when "="
                a, b = @stack.pop(2)
                @stack.push (a == b).to_i
            when "~"
                a, b = @stack.pop(2)
                @stack.push (a != b).to_i
            when "^"
                @data += @stack.map { |e| chr e rescue e } .join
            when "@"
                @stack.pop
            when ":"
                @stack.push @stack[-1]
            when "\\"
                a, b = @stack.pop(2)
                @stack.push b, a
            when "<"
                @i -= 1
            when ">"
                @i += 1
                
        end
    end
    
    def step
        @c = @data[@i]
        @stack << @c
        @implicit = true
        @build = ""
        @building = nil
        @debug_it = 1
        
        @j = 0
        @program.scan(/\d+|['`]?./).each { |op|
            action = exec_op op
            next if action == :next
            break if action == :break
            @j += op.size
        }
        $><< @stack.pop if @implicit
        @i += 1
    end
    
    def run
        loop {
            step
            break if @i >= @data.size
        }
    end
end

def premier(prog)
    program, *data = prog.lines
    program ||= ""
    program.chomp!
    if /^(\d+)(.*)/m === program
        program = $2
        $1.to_i.times {
            program += (data.shift || "").chomp
        }
    end
    program.strip!
    data = data.join("\n")
    
    state = PremState.new program, data
    state.run
end

premier File.open(ARGV[0], "r:UTF-8").read