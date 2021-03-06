require_relative "object"

module Virtual
  
  # Think flowcharts: blocks are the boxes. The smallest unit of linear code
  
  # Blocks must end in control instructions (jump/call/return). 
  # And the only valid argument for a jump is a Block 
  
  # Blocks form a graph, which is managed by the method
  
  class Block < Virtual::Object

    def initialize(name , method )
      super()
      @method = method
      @name = name.to_sym
      @branch = nil
      @codes = []
    end

    attr_reader :name , :codes , :method
    attr_accessor :branch
    
    def reachable ret = []
      add_next ret
      add_branch ret
      ret
    end

    def add_code kode
      @codes << kode
      self
    end

    # replace a code with an array of new codes. This is what happens in passes all the time
    def replace code , new_codes
      index = @codes.index code
      raise "Code not found #{code} in #{self}" unless index
      @codes.delete_at(index)
      if( new_codes.is_a? Array)
        new_codes.reverse.each {|c| @codes.insert(index , c)}
      else
        @codes.insert(index , new_codes)
      end
    end

    # returns if this is a block that ends in a call (and thus needs local variable handling)
    def call_block?
      return false unless codes.last.is_a?(CallInstruction)
      return false unless codes.last.opcode == :call
      codes.dup.reverse.find{ |c| c.is_a? StackInstruction }
    end

    # position is what another block uses to jump to. this is determined by the assembler
    # the assembler allso assembles and assumes a linear instruction sequence
    # Note: this will have to change for plocks and maybe anyway. back to oo, no more visitors
    def set_position at
      @position = at
      @codes.each do |code|
        code.set_position( at)
        raise code.inspect unless code.mem_length
        at += code.mem_length
      end
    end

    def mem_length
      @codes.inject(0){|count , instruction| count += instruction.mem_length }
    end

    private
    # helper for determining reachable blocks 
    def add_next ret
      return if @next.nil?
      return if ret.include? @next
      ret << @next
      @next.reachable ret
    end
    # helper for determining reachable blocks 
    def add_branch ret
      return if @branch.nil?
      return if ret.include? @branch
      ret << @branch
      @branch.reachable ret
    end
  end
end