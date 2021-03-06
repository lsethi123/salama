module Virtual
  # The Virtual Machine is a value based virtual machine in which ruby is implemented. While it is value based,
  # it resembles oo in basic ways of object encapsulation and method invokation, it is a "closed" / static sytem
  # in that all types are know and there is no dynamic dispatch (so we don't bite our tail here).
  #
  # It is minimal and realistic and low level
  # - minimal means that if one thing can be implemented by another, it is left out. This is quite the opposite from
  #          ruby, which has several loops, many redundant if forms and the like.
  # - realistic means it is easy to implement on a 32 bit machine (arm) and possibly 64 bit. Memory access, a stack,
  #    some registers of same size are the underlying hardware. (not ie byte machine)
  # - low level means it's basic instructions are realively easily implemented in a register machine. ie send is not
  #   a an instruction but a function.
  #
  # So the memory model of the machine allows for indexed access into an "object" . A fixed number of objects exist
  # (ie garbage collection is reclaming, not destroying and recreating) although there may be a way to increase that number.
  #
  # The ast is transformed to virtaul-machine objects, some of which represent code, some data.
  # 
  # The next step transforms to the register machine layer, which is what actually executes. 
  #

  # More concretely, a virtual machine is a sort of oo turing machine, it has a current instruction, executes the
  # instructions, fetches the next one and so on. 
  # Off course the instructions are not soo simple, but in oo terms quite so.
  # 
  # The machine is virtual in the sense that it is completely modeled in software, 
  # it's complete state explicitly available (not implicitly by walking stacks or something)

  # The machine has a no register, but local variables, a scope at each point in time. 
  # Scope changes with calls and blocks, but is saved at each level. In terms of lower level implementation this means
  # that the the model is such that what is a variable in ruby, never ends up being just on the pysical stack.
  # 
  class Machine

    def initialize
      @parser  = Parser::Salama.new
      the_end = Halt.new
      @message = Message.new(the_end , the_end , :Object)
    end
    attr_reader :message

    def self.boot
      machine = Machine.new
      BootSpace.space.boot_classes! # boot is a verb here
      machine.boot
      machine
    end

    def boot
      # read all the files needed for a minimal system at compile
      classes = ["object"]
      classes.each do |clazz|
        bytes = File.read(File.join( File.dirname( __FILE__ ) , ".." , "parfait" , "#{clazz}.rb") )
#        expression = compile_main(bytes)
      end
    end

    def compile_main bytes
      syntax  = @parser.parse_with_debug(bytes)
      parts = Parser::Transform.new.apply(syntax)
      main = Virtual::CompiledMethod.main
      expressions = parts.compile( main , self.message )
    end


    # run the instruction stream given. Instructions are a graph and executing means traversing it.
    # If there is no next instruction the machine stops
    def run instruction
      while instruction do
        next_instruction = instruction.next
        instruction.execute
        instruction = next_instruction
      end
    end
  end
end

require_relative "instruction"
require_relative "compiled_method"
require_relative "frame"
require_relative "message"
require_relative "slot"
require_relative "type"
require_relative "object"
require_relative "constants"
require_relative "boot_space"
# the passes _are_ order dependant
require_relative "passes/send_implementation"
require_relative "passes/get_implementation"
require_relative "passes/enter_implementation"
require_relative "passes/frame_implementation"

Sof::Volotile.add(Virtual::Block ,  [:method])
Sof::Volotile.add(Virtual::CompiledMethod ,  [:current])
