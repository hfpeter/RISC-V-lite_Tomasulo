`define opcode 31:26
`define addition 6'b001000 
`define multiplication 6'b111111 
`define source_register1 25:21
`define source_register2 20:16
`define dest_register    15:11

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
module CDB(rst,clk,instr,bus_out,
r_tag_flr2rsm,
r_tag_rsm2flr,
r_tag_flr2rsa,
r_tag_rsa2flr,
r_id_dest_flr2rs,
r_id_dest_rsa2flr,
r_id_dest_rsm2flr,
r_flr_data1,
r_flr_data2,
r_data_dest_m,
r_data_dest_a         
);
input  wire [31:0] instr;
output reg [31:0] bus_out;
input wire rst;
input wire clk;
 wire  [4:0] tag_flr2rsm_1,tag_flr2rsm_2,tag_rsm2flr,tag_flr2rsa_1,tag_flr2rsa_2,tag_rsa2flr,id_dest_flr2rs,id_dest_rsa2flr,id_dest_rsm2flr;
 wire [31:0] flr_data1_a,flr_data2_a,flr_data1_m,flr_data2_m,data_dest_m,data_dest_a;
wire [5:0] opcode2rs;
reg [31:0] data_dest;

output reg [4:0] r_tag_flr2rsm;                       
output reg [4:0] r_tag_rsm2flr;                       
output reg [4:0] r_tag_flr2rsa;                       
output reg [4:0] r_tag_rsa2flr;                       
output reg [4:0] r_id_dest_flr2rs;                    
output reg [4:0] r_id_dest_rsa2flr;                   
output reg [4:0] r_id_dest_rsm2flr;                   
output reg [31:0] r_flr_data1;                        
output reg [31:0] r_flr_data2;                        
output reg [31:0] r_data_dest_m;                      
output reg [31:0] r_data_dest_a;   

assign bus_out=data_dest;
reservation_add reservation1 (clk,rst,
tag_flr2rsa_1,tag_flr2rsa_2,//tag_flr2rsa_1 needs one more, such as tag_flr2rsa_2
tag_rsa2flr,
id_dest_flr2rs,
flr_data1_a,flr_data2_a,
data_dest_a,id_dest_rsa2flr,
opcode2rs,tag_rsm2flr
);
reservation_mul reservation0 (clk,rst,
tag_flr2rsm_1,tag_flr2rsm_2,//tag_flr2rsm_1 needs one more, such as tag_flr2rsm_2
tag_rsm2flr,
id_dest_flr2rs,
flr_data1_m,flr_data2_m,
data_dest_m,id_dest_rsm2flr,
opcode2rs,tag_rsa2flr
);
FLR flr0(clk,rst,
        tag_flr2rsa_1,tag_flr2rsa_2,
				tag_rsa2flr,
				tag_flr2rsm_1,tag_flr2rsm_2,
				tag_rsm2flr,
        instr[`source_register1],instr[`source_register2],id_dest_flr2rs,id_dest_rsm2flr,
				id_dest_rsa2flr,
		flr_data1_a,flr_data2_a,
		flr_data1_m,flr_data2_m,
		data_dest_m,data_dest_a,instr,opcode2rs); 
		always @(flr_data1_a,flr_data2_a) begin
		r_flr_data1        =flr_data1_a        ;
		r_flr_data2        =flr_data2_a       ;		
		end 
		always @(flr_data1_m,flr_data2_m) begin
		r_flr_data1        =flr_data1_m        ;
		r_flr_data2        =flr_data2_m       ;		
		end 		
	always @(posedge clk,rst)begin
		if (rst==1) begin 
		end 	else begin 
r_tag_flr2rsm      =tag_flr2rsm_1      ;
r_tag_rsm2flr      =tag_rsm2flr      ;
r_tag_flr2rsa      =tag_flr2rsa_1      ;
r_tag_rsa2flr      =tag_rsa2flr      ;
r_id_dest_flr2rs   =id_dest_flr2rs   ;
r_id_dest_rsa2flr  =id_dest_rsa2flr  ;
r_id_dest_rsm2flr  =id_dest_rsm2flr  ;
//r_flr_data1        =flr_data1        ;
//r_flr_data2        =flr_data2        ;
r_data_dest_m      =data_dest_m      ;
r_data_dest_a      =data_dest_a      ; 			
		end 
	end
endmodule

/*arf2rrf: input is instruction, output is the 32 bit data .
输入其实是logic寄存器的序号，这个程序处理是根据logic寄存器
序号分配寄存器，输出寄存器的32位数据
*/
//----------------------------------------------------------------------------------------------------
module arf2rrf( ins,rst,data);
input  wire [31:0] ins;
input  wire  rst;
output reg [31:0] data;
//ARF: DATA 32bit, busy 1 bit, Tag 5 bit.
reg  [37:0]ARF[0:4];
//RRF: DATA 32bit, valid 1 bit, busy 1 bit.
reg  [33:0]RRF[0:4];
	always @(ins,rst)begin
	//if the opcode is 000000 then the dest is [15:11]
	//else the dest is [20:11]
	if (ins[31:26]==6'b000000) begin 
		for(integer n1=0;n1<32;n1++)begin
		  if(RRF[n1]&34'h0001==34'h0000)begin 
			  RRF[n1]=RRF[n1]|34'h000000001;//set   first bit, busy bit 
			  RRF[n1]=RRF[n1]&34'h3fffffffd;//reset 2nd bit, valid bit 
			  ARF[ins[15:11]]=n1;//UPDATE the map table with the rename reg tag 
			  ARF=ARF|38'h00000000020;//set the ARF busy bit 
		  break;
		  end		  
    end	
	end 
	data=ARF[0]>>8;//2;// 什么时候结束exe?
  end
endmodule 
//----------------------------------------------------------------------------------------------------
module ROB_RenameRF( ins,rst );
input  wire [31:0] ins;
input  wire  rst;
reg  [4:0] RealiasTable[0:4];
//reg  [31:0] physRspecifier[0:7];
reg  [4:0] physRspecifier[0:4];
reg  [4:0] freeList[0:4];
reg  [31:0] RenameRFarr[0:15];
//ARF: DATA 32bit, busy 1 bit, Tag 5 bit.
reg  [37:0]ARF[0:4];
//RRF: DATA 32bit, valid 1 bit, busy 1 bit.
reg  [33:0]RRF[0:4];

//reg  [35:0] rob_arr[0:7];
reg  [59:0] rob_arr[0:7];
	//ins[25:21];//instruction field [25:21]is the number of physical register file port a 
	//ins[20:16];//instruction field [20:16]is the number of physical register file port b
//Syntax:   add $d,$s,$t
//Encoding: 0000 00ss ssst tttt dddd d000 0010 0000    
	//assign rob_arr[7]=(ins[31:0]<<1)|(ready_done<<32)
	//|(destination<<40);
	always @(ins,rst)begin
	//physRspecifier[ins[25:21]]=1;//? 1 indicate is used
	//if the opcode is 000000 then the dest is [15:11]
	//else the dest is [20:11]
	if (ins[31:26]==6'b000000) begin 
	RealiasTable[0]=ins[15:11];
		for(integer n1=0;n1<32;n1++)begin
		  if(RRF[n1]&34'h0001==34'h0000)begin 
          RRF[n1]=RRF[n1]|34'h000000001;//set   first bit, busy bit 
		  RRF[n1]=RRF[n1]&34'h3fffffffd;//reset 2nd bit, valid bit 
		  ARF[ins[15:11]]=n1;//UPDATE the map table with the rename reg tag 
		  ARF=ARF|38'h00000000020;//set the ARF busy bit 
		  break;
		  end		  
        end	
	end 
	else 
	RealiasTable[0]=ins[20:16];
	//RealiasTable:index number is physical regs, content is logic regs 
    for(integer n=0;n<32;n++)begin
	RealiasTable[n]=RealiasTable[0];
    end
	end
endmodule 

//----------------------------------------------------------------------------------------------------
module INTSR_QUE(intr,intr_out);
	input [31:0] intr;
	output [31:0] intr_out;
	wire [31:0] que[0:5];
	assign que[0]=intr;
	assign que[1]=que[0];
	assign que[2]=que[1];
	assign que[3]=que[2];
	assign que[4]=que[3];
	assign que[5]=que[4];
	assign intr_out=que[5];
endmodule
//----------------------------------------------------------------------------------------------------
//Field        opcode       rs           rd              address
//Bit positions 31:26       25:21         20:16            15:0
module BTB(instr_in,brc_add,tag_pc,rst,take);
    input [31:0] instr_in;
    reg [31:0] instr_in;
	input [31:0] brc_add;
	input [31:0] tag_pc;
	input rst;
	output take;
	reg take;
	//check the instr if it is branch type: 
	//if it is, then while fetch stage, check the lookup array whether it match one of the entry
	reg  [31:0] lookup[0:15];
	//take some part of bits of instruction as the index of lookup[index], if(lookup[..]==instruciton) then take the branch
	//what is the range of bit represent the entry 
	reg [15:0] taken;
	//reg entry_cnt[7:0];
	//integer entry_cnt;
	reg [7:0]entry_cnt;
wire [5:0] instr_opcode;
assign instr_opcode=instr_in[31:26];	
    genvar i;
    generate
    for (i = 0; i <= 15; i = i + 1) begin
      match     match0(lookup[i],instr_in,taken[i]);
    end
    endgenerate
	

	always @(instr_opcode,rst)begin

	if(rst==1)
	begin		
		entry_cnt=0;
	   //assign taken=0;  //must not use assgin here, otherwise the value always be 0
	end	  		
	if (instr_opcode==6'b000100) begin //beq opcode is 0001 00	
	//if vector "taken" is not zero then there is at least one mach
				if (taken==16'h0000) begin //if "taken" is zero and the BTB is full then delete the oldest entry of the BTB, replace with this instruction 
				//if the BTB is not full just append this instruction in the end 
						if (entry_cnt <=15) begin 
							lookup[entry_cnt]=instr_in;
							entry_cnt++;
							end 
						else begin 
					//BTB is full then delete the oldest entry of the BTB
					lookup[0 ]=lookup[1];
					lookup[1 ]=lookup[2];
					lookup[2 ]=lookup[3];
					lookup[3 ]=lookup[4];
					lookup[4 ]=lookup[5];
					lookup[5 ]=lookup[6];
					lookup[6 ]=lookup[7];
					lookup[7 ]=lookup[8];
					lookup[8 ]=lookup[9];
					lookup[9 ]=lookup[10];
					lookup[10]=lookup[11];
					lookup[11]=lookup[12];
					lookup[12]=lookup[13];
					lookup[13]=lookup[14];
					lookup[14]=lookup[15];
					lookup[15]=instr_in;					
						end 
						take=0;
				end else begin
						take = 1;
						end 
				end		
    else begin 
	     if (taken!=16'h0000) begin
		 take = 1;
		 end
    end 
	
	end
endmodule
//----------------------------------------------------------------------------------------------------
module match(lookup,instr,taken);
input [31:0] lookup ;
input [31:0] instr ;//[...] must be in front of name, otherwise the "always" can only detect one bit 
wire [31:0] instr ;
wire [7:0] instr_opcode;
output taken;// taken is one bit
wire taken;
//reg taken;
//reg instr [31:0];
reg takens;
integer instmp;

assign instr_opcode=instr[31:24];
//assign  taken=1;
assign  taken=takens;
 //initial begin
	//assign instmp[31:0]=instr[31:0]; 
	//instmp= $bits(instr);
	//instmp = $unsigned(instr);
	//
	//instr = 32'b01010101010101010101010101010101;
	//instmp = instr;

	always @(instr_opcode)begin
	//always @(instr[31])begin
	//always @(integer(instr))begin
	//assign taken=takens;
	//taken<=takens;
			if (lookup==instr) begin
			 //assign  taken=1;
			takens=1;
			 //taken<=takens;
			end
		    else begin
			//assign  taken=0;
		takens=0;
			end
	end
//end 
endmodule

// import the multiplier from the previous lab
// as the FP MULTIPLIER

