#!/usr/bin/env ruby

#s = File.open("hello.bin","rb") {|io|  io.read }
#puts s.encoding

#s.each_line do | x |
#	puts x.unpack('a*')
#end

# all of this are taken from ARM ARM (ARM Architecture Reference Manual)

#mask for Multiply

MUL_mask_list = (22..27).to_a + (4..7).to_a
MUL_pattern = (0b1001)<<4

sum = 0
MUL_mask_list.each do | n | 
	sum += 1<<n
end

$MUL_mask = sum
#puts "MUL_mask: #{sum}"
#puts "MUL_mask: #{MUL_mask}"

#mask for Data Processing Instructions
DP_mask_list = (26..27).to_a
DP_pattern = 0b00<<26 #is just = zero

sum = 0
DP_mask_list.each do | n | 
	sum += 1<<n	
end

$DP_mask = sum


#mask for SWAP
SWP_mask_list = (4..11).to_a + (20..21).to_a + (23..27).to_a
SWP_pattern = 0b1<<24 + (0b1001)<<4

sum = 0
SWP_mask_list.each do | n | 
	sum += 1<<n	
end

$SWP_mask = sum



require 'bindata'

class InstBits < BinData::Record
  endian :little
  uint16 :ins
end

class Instruction 
	def initialize(bitpattern)
		@inst = bitpattern
	end
end

def bit_range num, low, high
    len = high - low + 1
    num >> low & ~(-1 >> len << len)
end

def getInstruction(io)
	y = InstBits.read(io).ins.to_i
	x = InstBits.read(io).ins.to_i
	(x<<16) + y
end

def is_a_MUL? (ins)
	abort unless ins.is_a? Integer
	#puts "(ins) #{ins}"
	tmp = (ins & $MUL_mask)
	#puts "#{tmp} and #{MUL_pattern} and #{ins.to_s(16)}"
	MUL_pattern == tmp	
end

def is_a_DP? (ins)
	tmp = ins & $DP_mask
	DP_pattern == tmp	
end

def is_a_SWP? (ins)
	tmp = ins & $SWP_mask
	DP_pattern == tmp	
end

# open file
io = File.open("bin/swp.bin","rb")


(1..5).each do | x |
	inst = getInstruction(io)
	inst_str = inst.to_s(16)

	if is_a_MUL? (inst)
		puts "#{inst_str} is a MULTIPLY"
	elsif is_a_SWP?(inst)
		puts "#{inst_str} is a Swap Instruction"
	elsif is_a_DP?(inst)
		puts "#{inst_str} is a Data Processing"	
	end
end

#get 1 instruction and analyze it

#r = InstBits.read(io)
#hexx = r.ins.to_i
#hexx2 = (Inst.read(io)).ins.to_i

#hexx2 = (hexx2<<16) + hexx

#puts "inst #{hexx2.to_s(16)}"

#t = bit_range(hexx2, 26,27)

#puts "type: #{t}"
