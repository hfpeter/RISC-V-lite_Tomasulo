

//---------------flr: FLoating point Register-------------------------------------------------------------------------------------
module FLR(clk,rst,
		tag_flr2rsa_1,tag_flr2rsa_2,
		tag_rsa2flr,
		tag_flr2rsm_1,tag_flr2rsm_2,
		tag_rsm2flr,
    id1,id2,id_dest_flr2rs,id_dest_rsm2flr,id_dest_rsa2flr,
		flr_data1_a,flr_data2_a,
		flr_data1_m,flr_data2_m,
		data_dest_m,data_dest_a,instr,
		opcode2rs
		);
input wire clk,rst;
output reg[4:0] tag_flr2rsa_1,tag_flr2rsa_2,id_dest_flr2rs;
input wire[4:0] tag_rsa2flr;
output reg[4:0] tag_flr2rsm_1,tag_flr2rsm_2;
input wire[4:0] tag_rsm2flr;
input wire[4:0] id1,id2,id_dest_rsm2flr,id_dest_rsa2flr;
//output reg [31:0]flr_data1,flr_data2;
output reg [31:0]flr_data1_a,flr_data2_a;
output reg [31:0]flr_data1_m,flr_data2_m;
input  wire[31:0] data_dest_m,data_dest_a,instr;
reg [37:0]rs_arr[31:0];//5+32+5+32=74
output reg [6:0] opcode2rs;
reg [1:0] mul_add;
integer destm_i,desta_i;
always @(data_dest_m)begin : dest_m_loop
if(rst==0) begin
		if(data_dest_m==32'hffffffff)
		disable dest_m_loop;
		mul_add=mul_add|1;	
		for(integer n2=0;n2<32;n2++)begin
			if (0==rs_arr[n2][37])begin
				if(tag_rsm2flr==rs_arr[n2][36:32])begin
					destm_i=n2;
					rs_arr[n2][31:0]=data_dest_m;				
					rs_arr[n2][36:32]=tag_rsm2flr;		
					disable dest_m_loop;
					break;
				end 
			end
		end		
    mul_add<=0;
		//following code:when the tag was updated by newest intrs, then broadcast tag and data back to RS
		//means the loop above is no one match
		tag_flr2rsa_1=tag_rsm2flr;
		tag_flr2rsa_2=tag_rsm2flr;
		tag_flr2rsm_1  =tag_rsm2flr;
		tag_flr2rsm_2=tag_rsm2flr;
		flr_data1_m =data_dest_m;
		flr_data2_m =data_dest_m;
		flr_data1_a =data_dest_m;
		flr_data2_a =data_dest_m;		
	end
end
always @(data_dest_a)begin : dest_a_loop
if(rst==0) begin
		if(data_dest_a==32'hffffffff)
		disable dest_a_loop;
		mul_add=mul_add|2;	
		for(integer na=0;na<32;na++)begin
			if (0==rs_arr[na][37])begin
				if((tag_rsa2flr)==rs_arr[na][36:32])begin
					desta_i=na;
					rs_arr[na][31:0]=data_dest_a;				
					rs_arr[na][36:32]=tag_rsa2flr;	
					disable dest_a_loop;
					break;
				end 
			end
		end
    mul_add<=0;
		tag_flr2rsa_1=tag_rsa2flr;
		tag_flr2rsa_2=tag_rsa2flr;
		tag_flr2rsm_1  =tag_rsa2flr;
		tag_flr2rsm_2=tag_rsa2flr;
		flr_data1_m =data_dest_a;
		flr_data2_m =data_dest_a;
		flr_data1_a =data_dest_a;
		flr_data2_a =data_dest_a;
	end
end
always @(rst, clk)begin
if(rst==0) begin
		if(mul_add==1)
		begin
				mul_add<=0;
				rs_arr[destm_i][37]=1;			
				tag_flr2rsa_1  =rs_arr[destm_i][36:32];		
				tag_flr2rsa_2=rs_arr[destm_i][36:32];		
				tag_flr2rsm_1  =rs_arr[destm_i][36:32];			//?
				tag_flr2rsm_2=rs_arr[destm_i][36:32];	
				flr_data1_m =rs_arr[destm_i][31:0];
				flr_data2_m =rs_arr[destm_i][31:0];
				flr_data1_a =rs_arr[destm_i][31:0];
				flr_data2_a =rs_arr[destm_i][31:0];		
				rs_arr[destm_i][37:32]=6'b111111;	
		end 
		if (mul_add==2)
		begin
				mul_add<=0;
				rs_arr[desta_i][37]=1;						
				tag_flr2rsa_1  =rs_arr[desta_i][36:32];	
				tag_flr2rsa_2=rs_arr[desta_i][36:32];	
				tag_flr2rsm_1  =rs_arr[desta_i][36:32];			
				tag_flr2rsm_2=rs_arr[desta_i][36:32];			
				flr_data1_m =rs_arr[desta_i][31:0];
				flr_data2_m =rs_arr[desta_i][31:0];
				flr_data1_a =rs_arr[desta_i][31:0];
				flr_data2_a =rs_arr[desta_i][31:0];				
				rs_arr[desta_i][37:32]=6'b111111;					
		end 		
		if(mul_add==3)
		begin//when mul and add happen together, stall the isntr fetch
				mul_add=2;		
				rs_arr[destm_i][37]=1;			
				tag_flr2rsa_1  =rs_arr[destm_i][36:32];		
				tag_flr2rsa_2=rs_arr[destm_i][36:32];	
				tag_flr2rsm_1  =rs_arr[destm_i][36:32];			
				tag_flr2rsm_2=rs_arr[destm_i][36:32];				
				flr_data1_m =rs_arr[destm_i][31:0];
				flr_data2_m =rs_arr[destm_i][31:0];
				flr_data1_a =rs_arr[destm_i][31:0];
				flr_data2_a =rs_arr[destm_i][31:0];		
				rs_arr[destm_i][37:32]=6'b111111;					

		end 	
		end
end		
always @(tag_rsm2flr)	begin: tag_no_data_m		
	if(rst==0) begin
			//if((rs_arr[id_dest_rsm2flr][37]==1)&&(tag_rsm2flr!=5'b11111&&(tag_rsm2flr>=0)))begin
		if(data_dest_m!=32'hffffffff)
		disable tag_no_data_m;
		if((tag_rsm2flr!=5'b11111)&&(tag_rsm2flr>=0)&&(id_dest_rsm2flr>=0))begin
		rs_arr[id_dest_rsm2flr][36:32]=tag_rsm2flr;//+1;//tag_rs2flr1 dest reg address
		rs_arr[id_dest_rsm2flr][37]=0;
		rs_arr[id_dest_rsm2flr][31:0]='{default:1'bz};
		//tag_flr2rsm_1=tag_rsm2flr;
		end
	end
end		
always @(tag_rsa2flr)begin: tag_no_data_a	
if(rst==0) begin
//if((rs_arr[id_dest_rsa2flr][37]==1)&&(tag_rsa2flr!=5'b11111)&&(tag_rsa2flr>=0))begin
		if(data_dest_a!=32'hffffffff)
		disable tag_no_data_a;
		if((tag_rsa2flr!=5'b11111)&&(tag_rsa2flr>=0)&&(id_dest_rsa2flr>=0))begin
				rs_arr[id_dest_rsa2flr][36:32]=tag_rsa2flr;//+1;//tag_rsa2flr是输入没办法在同一个周期更新
				rs_arr[id_dest_rsa2flr][37]=0;
				rs_arr[id_dest_rsa2flr][31:0]='{default:1'bz};
				//tag_flr2rsa_1=tag_rsa2flr;
		end
end
end		

always @(rst,  negedge clk)begin
//always @(rst,  mul_add)begin
if(rst==0) begin
if(mul_add==0)begin
	flr_data1_a='{default:1'bz};
	flr_data2_a='{default:1'bz};
	tag_flr2rsa_1='{default:1'b1};			
	tag_flr2rsa_2='{default:1'b1};
	flr_data1_m='{default:1'bz};			
	flr_data2_m='{default:1'bz};
	tag_flr2rsm_1='{default:1'b1};		
	tag_flr2rsm_2='{default:1'b1};
	end			
end 
end 
always @(rst,//index_d
posedge clk//,
//id1,id2
)begin
if(rst==1) begin 
	for(reg unsigned [31:0] n1=0;n1<32;n1++)begin
	rs_arr[n1][37]=1;
	rs_arr[n1][31:0]=32'h00000000;
	rs_arr[n1][36:32]=5'bzzzzz;
	end
	rs_arr[1][31:0]=32'h00000001;	
	rs_arr[2][31:0]=32'h00000002;
	rs_arr[3][31:0]=32'h00000003;
	rs_arr[4][31:0]=32'h00000004;
	rs_arr[5][31:0]=32'h00000005;	
	rs_arr[6][31:0]=32'h00000006;
	rs_arr[7][31:0]=32'h00000007;
	rs_arr[8][31:0]=32'h00000008;
	rs_arr[9][31:0]=32'h00000009;
	rs_arr[10][31:0]=32'h0000000a;
	rs_arr[11][31:0]=32'h0000000b;	
	flr_data1_a <= '{default:1'bz};
	flr_data2_a<= '{default:1'bz};
	flr_data1_m <= '{default:1'bz};
	flr_data2_m<= '{default:1'bz};
mul_add=0;
	/*tag_flr2rsm_1<=0;
	tag_flr2rsa_1<=0;
	tag_flr2rsm_2<=0;
	tag_flr2rsa_2<=0;*/	
end else begin 
if(clk==1)begin
		opcode2rs=instr[31:26];			
		if(instr[31:26]==6'b001000) begin //i type 
			if(rs_arr[id1][37]==1) begin //check busy bit 
			flr_data1_a =rs_arr[id1][31:0];
			end 
			flr_data2_a[15:0]=instr[15:0];
			flr_data2_a[31:16]= '{default:0}; //imm num 	
			id_dest_flr2rs<=instr[20:16];		
		end 
		else  
				if(instr[31:26]==6'b111011) begin //mul  乘法指令暂时的OPCODE是 1110 11
					if(rs_arr[id1][37]==1) begin //check busy bit 
					    flr_data1_m =rs_arr[id1][31:0];
							tag_flr2rsm_1='{default:1'b1};					
					end //这里要告诉RS如果32bit数据不存在的情况
					else begin
							flr_data1_m='{default:1'bz};//broadcast tag isntead of 32 bit data		
							tag_flr2rsm_1=rs_arr[id1][36:32];
					end 
					if (rs_arr[id2][37]==1) begin //check busy bit 
							flr_data2_m=rs_arr[id2][31:0];
							tag_flr2rsm_2='{default:1'b1};		
					end 	
					   else begin
							flr_data2_m='{default:1'bz};			
							tag_flr2rsm_2=rs_arr[id2][36:32];
					end 
					id_dest_flr2rs=instr[15:11];
					rs_arr[instr[15:11]][37]<=0;	
					flr_data1_a='{default:1'bz};
					flr_data2_a='{default:1'bz};
					tag_flr2rsa_1='{default:1'b1};			
					tag_flr2rsa_2='{default:1'b1};					
					//rs_arr[instr[15:11]][31:0]<='{default:1'bz};
				end
		 		
		else  
				if(instr[31:26]==6'b000000) begin //r type 
					if(instr[7:0]==32) begin 
							if(rs_arr[id1][37]==1) begin //check busy bit 
									flr_data1_a =rs_arr[id1][31:0];
									tag_flr2rsa_1='{default:1'b1};				
							end 
							else begin	   
									flr_data1_a='{default:1'bz};//addition, broadcast tag isntead of 32 bit data		
									tag_flr2rsa_1=rs_arr[id1][36:32];
							end 	
							if (rs_arr[id2][37]==1) begin //check busy bit 
									flr_data2_a=rs_arr[id2][31:0];
									tag_flr2rsa_2='{default:1'b1};				
							end 	
							else begin
									flr_data2_a='{default:1'bz};			
									tag_flr2rsa_2=rs_arr[id2][36:32];
							end 		
							id_dest_flr2rs=instr[15:11];
							flr_data1_m='{default:1'bz};			
							flr_data2_m='{default:1'bz};
							tag_flr2rsm_1='{default:1'b1};		
							tag_flr2rsm_2='{default:1'b1};					
							//rs_arr[instr[15:11]][37]=0;			
							end 
						
				end
		      
	end 
	end 
	end

endmodule 
