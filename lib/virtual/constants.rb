module Virtual
  
  class Constant < ::Virtual::Object
  end
  class TrueConstant < Constant
  end
  class FalseConstant < Constant
  end
  class NilConstant < Constant
  end

  # another abstract "marker" class (so we can check for it)
  # derived classes are Boot/Meta Class and StringConstant 
  class ObjectConstant < Constant
    def type
      Virtual::Reference
    end
    def clazz
      raise "abstract #{self}"
    end
  end

  class IntegerConstant < Constant
    def initialize int
      @integer = int
    end
    attr_reader :integer
    def type
      Virtual::Integer
    end
    def fits_u8?
      integer >= 0 and integer <= 255
    end
  end

  # The name really says it all.
  # The only interesting thing is storage.
  # Currently string are stored "inline" , ie in the code segment. 
  # Mainly because that works an i aint no elf expert.
  
  class StringConstant < ObjectConstant
    def initialize str
      @string = str
    end
    attr_reader :string

    def result= value
      raise "called"
      class_for(MoveInstruction).new(value , self , :opcode => :mov)
    end
    def clazz
      BootSpace.space.get_or_create_class(:String)
    end
    def layout
      Virtual::Object.layout
    end
    def mem_length
      padded(1 + string.length)
    end
    def position
      return @position if @position
      return @string.position if @string.position
      super
    end
  end
  
end