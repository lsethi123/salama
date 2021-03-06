module Arm
  class LogicInstruction < Instruction
    include Arm::Constants
    #  result = left op right
    # 
    # Logic instruction are your basic operator implementation. But unlike the (normal) code we write
    #    these Instructions must have "place" to write their results. Ie when you write 4 + 5 in ruby
    #    the result is sort of up in the air, but with Instructions the result must be assigned 
    def initialize(result , left , right , attributes = {})
      super(attributes)
      @result = result
      @left = left
      @right = right.is_a?(Fixnum) ? Virtual::IntegerConstant.new(right) : right
      @attributes[:update_status] = 0 if @attributes[:update_status] == nil
      @attributes[:condition_code] = :al if @attributes[:condition_code] == nil
      @operand = 0

      raise "Left arg must be given #{inspect}" unless @left
      @immediate = 0      
    end

    attr_accessor :result , :left ,  :right
    def assemble(io)
      # don't overwrite instance variables, to make assembly repeatable
      left = @left
      operand = @operand
      immediate = @immediate

      right = @right
      if @left.is_a?(Virtual::ObjectConstant)
        # do pc relative addressing with the difference to the instuction
        # 8 is for the funny pipeline adjustment (ie pointing to fetch and not execute)
        right = @left.position - self.position - 8 
        left = :pc
      end
      # automatic wrapping, for machine internal code and testing
      if( right.is_a? Fixnum )
        right = Virtual::IntegerConstant.new( right )
      end
      if (right.is_a?(Virtual::IntegerConstant))
        if (right.fits_u8?)
          # no shifting needed
          operand = right.integer
          immediate = 1
        elsif (op_with_rot = calculate_u8_with_rr(right))
          operand = op_with_rot
          immediate = 1
        else
          raise "cannot fit numeric literal argument in operand #{right.inspect}"
        end
      elsif (right.is_a?(Symbol) or right.is_a?(::Register::RegisterReference))
        operand = reg_code(right)    #integer means the register the integer is in (otherwise constant)
        immediate = 0                # ie not immediate is register
      else
        raise "invalid operand argument #{right.inspect} , #{inspect}"
      end
      op =  shift_handling
      instuction_class = 0b00 # OPC_DATA_PROCESSING
      val = shift(operand , 0)
      val |= shift(op , 0) # any barral action, is already shifted
      val |= shift(reg_code(@result) ,            12)     
      val |= shift(reg_code(left) ,            12+4)   
      val |= shift(@attributes[:update_status] , 12+4+4)#20 
      val |= shift(op_bit_code ,        12+4+4  +1)
      val |= shift(immediate ,                  12+4+4  +1+4) 
      val |= shift(instuction_class ,   12+4+4  +1+4+1) 
      val |= shift(cond_bit_code ,      12+4+4  +1+4+1+2)
      io.write_uint32 val
    end
    def shift val , by
      raise "Not integer #{val}:#{val.class} #{inspect}" unless val.is_a? Fixnum
      val << by
    end
  
    def uses
      ret = []
      ret << @left.register if @left and not @left.is_a? Constant
      ret << @right.register if @right and not @right.is_a?(Constant)
      ret
    end
    def assigns
      [@result.register]
    end
  end
end
