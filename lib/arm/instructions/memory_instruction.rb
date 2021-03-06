module Arm
  # ADDRESSING MODE 2
  # Implemented: immediate offset with offset=0
  
  class MemoryInstruction < Instruction
    include Arm::Constants
    def initialize result , left , right = nil , attributes = {}
      super(attributes)
      @result = result
      @left = left
      @right = right
      @attributes[:update_status] = 0 if @attributes[:update_status] == nil
      @attributes[:condition_code] = :al if @attributes[:condition_code] == nil
      @operand = 0
      raise "alert" if right.is_a? Virtual::Block
      @pre_post_index = 0 #P flag
      @add_offset = 0 #U flag
      @is_load = opcode.to_s[0] == "l" ? 1 : 0 #L (load) flag
    end

    def assemble(io )
      # don't overwrite instance variables, to make assembly repeatable
      rn = @rn
      operand = @operand
      add_offset = @add_offset
      arg = @left
      arg = arg.symbol if( arg.is_a? ::Register::RegisterReference )
      #str / ldr are _serious instructions. With BIG possibilities not half are implemented
      if (arg.is_a?(Symbol) or arg.is_a?(::Register::RegisterReference)) #symbol is register
        rn = arg
        if @right
          operand = @right
          #TODO better test, this operand integer (register) does not work. but sleep first
          operand = operand.symbol if operand.is_a? ::Register::RegisterReference
          unless( operand.is_a? Symbol)
            #puts "operand #{operand.inspect}"
            if (operand < 0)
              add_offset = 0
              #TODO test/check/understand
              operand *= -1
            else
              add_offset = 1
            end
            if (@operand.abs > 4095)
              raise "reference offset too large/small (max 4095) #{arg} #{inspect}"
            end
          end
        end
      elsif (arg.is_a?(Virtual::ObjectConstant) ) #use pc relative
        rn = :pc
        operand = arg.position - self.position  - 8 #stringtable is after code
        add_offset = 1
        if (operand.abs > 4095)
          raise "reference offset too large/small (max 4095) #{arg} #{inspect}"
        end
      elsif( arg.is_a?(Virtual::IntegerConstant) )
        #TODO untested brach, probably not working
        raise "is this working ??  #{arg} #{inspect}"
        @pre_post_index = 1
        @rn = pc
        @use_addrtable_reloc = true
        @addrtable_reloc_target = arg
      else
        raise "invalid operand argument #{arg.inspect} #{inspect}"
      end
      #not sure about these 2 constants. They produce the correct output for str r0 , r1
      # but i can't help thinking that that is because they are not used in that instruction and
      # so it doesn't matter. Will see
      add_offset = 1
      # TODO to be continued
      add_offset = 0 if @attributes[:add_offset]
      @pre_post_index = 1
      @pre_post_index = 0 if @attributes[:flaggie]
      w = 0 #W flag
      byte_access = opcode.to_s[-1] == "b" ? 1 : 0 #B (byte) flag
      instuction_class =  0b01 # OPC_MEMORY_ACCESS
      if (operand.is_a?(Symbol) or operand.is_a?(::Register::RegisterReference))
        val = reg_code(operand) 
        @pre_post_index = 0
        i = 1  # not quite sure about this, but it gives the output of as. read read read.
      else
        i = 0 #I flag (third bit)
        val = operand
      end
      val = shift(val , 0 ) # for the test
      val |= shift(reg_code(@result) ,        12 )  
      val |= shift(reg_code(rn) ,        12+4) #16  
      val |= shift(@is_load ,        12+4  +4)
      val |= shift(w ,              12+4  +4+1)
      val |= shift(byte_access ,    12+4  +4+1+1)
      val |= shift(add_offset ,    12+4  +4+1+1+1)
      val |= shift(@pre_post_index, 12+4  +4+1+1+1+1)#24
      val |= shift(i ,              12+4  +4+1+1+1+1  +1)
      val |= shift(instuction_class,12+4  +4+1+1+1+1  +1+1)  
      val |= shift(cond_bit_code ,  12+4  +4+1+1+1+1  +1+1+2)
      io.write_uint32 val
    end
    def shift val , by
      raise "Not integer #{val}:#{val.class} #{inspect}" unless val.is_a? Fixnum
      val << by
    end

    def uses
      ret = [@left.register ]
      ret << @right.register unless @right.nil?
      ret
    end
    def assigns
      [@result.register]
    end
  end
end