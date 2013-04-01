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
DP_pattern = (0b00)<<26 #is just = zero

sum = 0
DP_mask_list.each do | n | 
	sum += 1<<n	
end

$DP_mask = sum


#mask for SWAP
SWP_mask_list = (4..11).to_a + (20..21).to_a + (23..27).to_a
SWP_pattern = ((0b1)<<24) + ((0b1001)<<4)

sumx = 0

SWP_mask_list.each do | n | 
	sumx += 1<<n	
end

$SWP_mask = sumx



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
	abort unless ins.is_a? Integer
	tmp = (ins & $DP_mask)
	DP_pattern == tmp	
end

def is_a_SWP? (ins)
	abort unless ins.is_a? Integer
	tmp = (ins & $SWP_mask)
	#puts "#{tmp} and #{SWP_pattern} and #{ins.to_s(16)}"
	SWP_pattern == tmp	
end

def condition(ins)
	tmp = (ins>>28) & (0xF)
	
	if (tmp == 0)
		"EQ"
	elsif (tmp == 1)
		"NE"
	elsif (tmp == 2)
		"CS"
	elsif (tmp == 3)
		"CC"
	elsif (tmp == 4)
		"MI"
	elsif (tmp == 5)
		"PL"
	elsif (tmp == 6)
		"VS"
	elsif (tmp == 7)
		"VC"
	elsif (tmp == 8)
		"HI"
	elsif (tmp == 9)
		"LS"
	elsif (tmp == 10)
		"GE"
	elsif (tmp == 11)
		"LT"
	elsif (tmp == 12)
		"GT"
	elsif (tmp == 13)
		"LE"
	elsif (tmp == 14)#always, but we don't have to put it
		""
	elsif (tmp == 15)
		"NV"
	end
end

def S_update? (ins)
	abort unless ins.is_a? Integer
	((ins >> 20) & 0b1) == 1
end

def getRd(ins) #destination register
	abort unless ins.is_a? Integer
	rd_position = 12
	("r" + ((ins >> rd_position) & 0xF).to_i.to_s)
end

def getRn(ins) #first operand
	abort unless ins.is_a? Integer
	rn_position = 16
	("r" + ((ins >> rn_position) & 0xF).to_i.to_s)
end

def getR2(ins) #second operand register only
	true
end

def opcode_DP(ins)
	tmp =( (ins>>21) & (0xF) )

	if (tmp == 0x0)
		"AND"
	elsif (tmp == 0b0001)
		"EOR"
	elsif (tmp == 0b0010)
		"SUB"
	elsif (tmp == 0b0011)
		"RSB"
	elsif (tmp == 0b0100)
		"ADD"
	elsif (tmp == 0b0101)
		"ADC"
	elsif (tmp == 0b0110)
		"SBC"
	elsif (tmp == 0b0111)
		"RSC"
	elsif (tmp == 0b1000)
		"TST"
	elsif (tmp == 0b1001)
		"TEQ"
	elsif (tmp == 0b1010)
		"CMP"
	elsif (tmp == 0b1011)
		"CMN"
	elsif (tmp == 0b1100)
		"ORR"
	elsif (tmp == 0b1101)
		"MOV"
	elsif (tmp == 0b1110)
		"BIC"
	elsif (tmp == 0b1111)
		"MVN"
	else 
		puts "unknown Data Processing instruction"
		abort
	end
end

def matchp (st,en,ins,pattern) # matches with start,end bits, with the pattern
	abort unless pattern.is_a? Integer
	abort unless ins.is_a? Integer
	abort unless st.is_a? Integer
	abort unless en.is_a? Integer

	mask = 1
	(1...(en-st+1)).each do | x |
		mask = (mask<<1) + 1		
	end

	tmp = (ins>>st) & mask
	tmp == pattern
	
end

def extract (st,en,ins)
	mask = 1
	(1...(en-st+1)).each do | x |
		mask = (mask<<1) + 1		
	end
	((ins>>st) & mask)
end

# open file
io = File.open("bin/and.bin","rb")


while !io.eof? # read until there are no more instructions

	inst = getInstruction(io)
	
	inst_str = inst.to_s(16)

	if is_a_MUL? (inst)
		puts "#{inst_str} is a MULTIPLY"
	elsif is_a_SWP?(inst)
		puts "#{inst_str} is a Swap Instruction"
	elsif is_a_DP?(inst)
		#puts "#{inst_str} is a Data Processing"	
		opc = opcode_DP(inst)



		oprd = "r" + extract(12,15,inst).to_s
		oprn = "r" + extract(16,19,inst).to_s
		oprm = "r" + extract(0,3,inst).to_s
		opr2=""
		#check type of Operand2 when not immediate
		if (matchp(25,25,inst,1))# this is an immediate value
			rotateval = extract(8,11,inst) * 2 #must be x2 due to even number shifting
			baseval = extract(0,7,inst)

			unless rotateval == 0
				val = (baseval<<32) >> rotateval
			else
				val = baseval
			end
			

			oprm = "#" + val.to_s #this is an imm value
		elsif matchp(4,4,inst,0)
			#puts "immediate shift"
			immval = extract(7,11,inst)
			if (immval > 0)
				if matchp(5,6,inst,0b00)
					opr2 += ", LSL "
				elsif matchp(5,6,inst,0b01)
					opr2 += ", LSR "
				elsif matchp(5,6,inst,0b10)
					opr2 += ", ASR "
				elsif matchp(5,6,inst,0b11)
					opr2 += ", ROR "
				end 
				opr2 += "#" + extract(7,11,inst).to_s
			end
		else
			if matchp(5,6,inst,0b00)
				opr2 += ", LSL "
			elsif matchp(5,6,inst,0b01)
				opr2 += ", LSR "
			elsif matchp(5,6,inst,0b10)
				opr2 += ", ASR "
			elsif matchp(5,6,inst,0b11)
				opr2 += ", ROR "
			end
			opr2 += "r" + extract(8,11,inst).to_s
		end
		cond = condition(inst)

		unless matchp(20,20,inst,1)
			status=""
		else
			status="s"
		end	
		
		print "#{opc}#{status}#{cond} #{oprd}, #{oprn}, #{oprm}#{opr2}\n"
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
