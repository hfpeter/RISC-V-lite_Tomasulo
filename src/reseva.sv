`define opcode 31:26
`define addition 6'b001000 
`define multiplication 6'b111111 
`define source_register1 25:21
`define source_register2 20:16
`define dest_register    15:11

module reservation_add (clk,rst,
tag_flr2rs_1,tag_flr2rs_2,
tag_rs2flr,
id_dest_flr2rs,
flr_data1,flr_data2,data_dest_a,id_dest_rs2flr,
opcode,tag_m2a
);  
 input clk, rst;
 input wire [4:0] id_dest_flr2rs,tag_flr2rs_1,tag_flr2rs_2,tag_m2a;
 input wire [31:0] flr_data1,flr_data2;
 output reg [31:0] data_dest_a;
 output reg [4:0] tag_rs2flr;
 output reg [31:0] id_dest_rs2flr;
 reg [4:0] tag_rs2add;
 wire [31:0] add2rs_out;
 input wire [5:0] opcode; //1+5+32+1+5+32=38+38
 wire add_busy;
 reg r_add_busy;
 reg gc;
bufif1 g_add_busy (add_busy,r_add_busy,gc);
reg [80:0] res_arr[0:7];//
reg [4:0] nzcnt;
reg [31:0] rdata1,rdata2,cnt;
reg [4:0] mtag,tmp1,tmp2;
reg  [102:0] arr [0:7];//
 always @( id_dest_flr2rs,rst) begin
 if(rst==0)begin//every time fetch, send tag to flr
  if((tag_flr2rs_1!=5'b11111)||(tag_flr2rs_2!=5'b11111)||(flr_data1>=0)||(flr_data2>=0))begin
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  (res_arr[n5][80:76]==id_dest_flr2rs)begin 
							tag_rs2flr=n5+8;
					   break;
				   end 
			   end//if no one is match in array,then store them in array 
	end
end				 
end			
 always @(	tag_flr2rs_1,tag_flr2rs_2,rst)  
 //always @(tag_flr2rs_1,tag_flr2rs_2,posedge clk,rst)
 //always @(posedge clk,rst)
begin: tag_loop
if(rst==0) begin 
		if ((tag_flr2rs_1!=5'b11111)) begin
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  ((res_arr[n5][75]==0)&&(res_arr[n5][74:70]==(tag_flr2rs_2 )&&(flr_data1>=0)))begin 
					  res_arr[n5][74:70]=5'b11111;
					  res_arr[n5][69:38]=flr_data1;
						res_arr[n5][75]=1;		
					  // break;
				   end 
			   end    
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  ((res_arr[n5][37]==0)&&(res_arr[n5][36:32]==(tag_flr2rs_1 ))&&(flr_data2>=0))begin 
					 res_arr[n5][36:32]=5'b11111;
						res_arr[n5][31:0]=flr_data2;   
						res_arr[n5][37]=1;			
					  // break;
				   end 
			   end  		   
		end	
			if((flr_data1>=0)&&(flr_data2>=0))begin
			end
				 else begin
				 if ((tag_flr2rs_1!=5'b11111)&&((tag_flr2rs_2!=5'b11111))) begin//if both operands are not available 
						for(integer n5=0;n5<=7;n5++)begin 
								if (tag_flr2rs_2==res_arr[n5][36:32])
								disable tag_loop;
								if (tag_flr2rs_1==res_arr[n5][74:70])
								disable tag_loop;
								if  ((res_arr[n5][37]==0)&&(res_arr[n5][75]==0))begin 
									res_arr[n5][80:76]=id_dest_flr2rs;   
									res_arr[n5][74:70]=tag_flr2rs_1;	
									res_arr[n5][36:32]=tag_flr2rs_2;		
									tag_rs2flr=n5+8;	
									id_dest_rs2flr=id_dest_flr2rs;
									disable tag_loop;
									break;
								end 
						end
				 end 		
				end 
		if ((tag_flr2rs_1!=5'b11111)&&(tag_flr2rs_2==5'b11111)) begin//this "if" following code handling the case "1 of operand available"
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  ((res_arr[n5][75]==0)&&(res_arr[n5][74:70]==tag_flr2rs_2 )&&(flr_data1>=0))begin 
							res_arr[n5][74:70]=5'b11111;
							res_arr[n5][69:38]=flr_data1;
							res_arr[n5][75]=1;// rs flag 1 is data valid, rs tag 11111 is data valid 
							res_arr[n5][36:32]=n5+8;	
							tag_rs2flr=n5+8;		
							res_arr[n5][80:76]=id_dest_flr2rs;
							id_dest_rs2flr=id_dest_flr2rs;								
							disable tag_loop;
							break;
				   end 
			   end 
		end   
		if ((tag_flr2rs_2!=5'b11111)&&(tag_flr2rs_1==5'b11111)) begin//this if following is 1 of operand available
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  ((res_arr[n5][37]==0)&&(res_arr[n5][36:32]==tag_flr2rs_1)&&(flr_data2>=0))begin 
							res_arr[n5][36:32]=5'b11111;
							res_arr[n5][31:0]=flr_data2;   
							res_arr[n5][37]=1;	
							res_arr[n5][74:70]=n5+8;	
							tag_rs2flr=n5+8;			
							res_arr[n5][80:76]=id_dest_flr2rs;
							id_dest_rs2flr=id_dest_flr2rs;													
							disable tag_loop;
							break;
				   end 
			   end  		   
		end	
end 
end 
 always @(flr_data1,flr_data2,rst)
 //always @(flr_data1,flr_data2,posedge clk,rst)
 //always @(posedge clk,rst)
  begin: data_loop
 if(rst==0)begin
    if ((flr_data1>=0)&&((flr_data2>=0))) begin 	//(opcode==6'b000000)&&
				for(integer n=0;n<=7;n++)begin 
						if((res_arr[n][37]==0)&&((tag_flr2rs_2 )==res_arr[n][36:32])&&(tag_flr2rs_1!=5'b11111)) begin
							res_arr[n][36:32]=5'b11111;
							res_arr[n][31:30]=flr_data1;
							res_arr[n][37]=1;		
							//disable data_loop;
							//break;
						end	
						if((res_arr[n][75]==0)&&((tag_flr2rs_1 )==res_arr[n][74:70])&&(tag_flr2rs_2!=5'b11111)) begin
								res_arr[n][74:70]=5'b11111;
								res_arr[n][69:38]=flr_data2;   
								res_arr[n][75]=1;							
								disable data_loop;
						end		
						if ((res_arr[n][75]==0)&&(res_arr[n][37]==0)&&(5'b11111==res_arr[n][74:70])&&(5'b11111==res_arr[n][36:32]) )
						begin 
								if((tag_flr2rs_1==5'b11111)&&(tag_flr2rs_2==5'b11111))begin
								res_arr[n][75]=1;
								res_arr[n][37]=1; 
								res_arr[n][80:76]=id_dest_flr2rs;
								res_arr[n][69:38]=flr_data1;
								res_arr[n][31:0]=flr_data2;						
								id_dest_rs2flr=id_dest_flr2rs;		
								tag_rs2flr=n+8;		
								disable data_loop;
								end
						end 
				end 		
		end 
			if ((flr_data1>=0)) begin //(opcode==6'b000000)&&
				for(integer n=0;n<=7;n++)begin 
					if (tag_flr2rs_2!=res_arr[n][36:32])begin
					//disable data_loop;				 				
					if ((res_arr[n][75]==0) &&(res_arr[n][37]==0)&&(5'b11111==res_arr[n][36:32])&&(5'b11111==res_arr[n][74:70]))begin 
					if(tag_flr2rs_1==5'b11111)begin
							res_arr[n][75]=1;
							res_arr[n][80:76]=id_dest_flr2rs;
							res_arr[n][69:38]=flr_data1;
							id_dest_rs2flr=id_dest_flr2rs;		
							tag_rs2flr=n+8;		
							res_arr[n][36:32]=tag_flr2rs_2;//from flr to rs, minus 8. How about RSM->FLR->RSA?
							disable data_loop;
							break;
						end
						end
					end 
			end //这两个寻址需不需要分开?需要分开，因为从FLR来的不一定有32bit数据，只有tag_flr2rs     
		end
		//else 
			if ((flr_data2>=0)) begin //(opcode==6'b000000)&&
				for(integer n5=0;n5<=7;n5++)begin 		
					if (tag_flr2rs_1!=res_arr[n5][74:70]) begin
					//disable data_loop;				
					if  ((res_arr[n5][75]==0)&&(res_arr[n5][37]==0)&&(5'b11111==res_arr[n5][36:32])&&(5'b11111==res_arr[n5][74:70]) )begin 
					if(tag_flr2rs_2==5'b11111)begin
						res_arr[n5][80:76]=id_dest_flr2rs;
						res_arr[n5][37]=1; 
						res_arr[n5][31:0]=flr_data2;		   
						id_dest_rs2flr=id_dest_flr2rs;	
						tag_rs2flr=n5+8;					
						//res_arr[n5][74:70]=n5;			
						res_arr[n5][74:70]=tag_flr2rs_1;//first time assign
						disable data_loop;
						break;
						end
						end
					end 
				end    
			end	 
end
end 

 always @(rst,posedge clk) begin 
	if (rst==1) begin 
	cnt=32'hffffffff;
	tag_rs2flr=5'bzzzzz;
	res_arr <= '{default:0};
	data_dest_a<=0;
	gc=1;
	r_add_busy=0;
	nzcnt=0;
	for(integer nr2=0;nr2<=7;nr2++)begin
			res_arr[nr2][36:32]<=5'b11111;
			res_arr[nr2][74:70]<=5'b11111;
			res_arr[nr2][75]=1'bz;
			res_arr[nr2][37]=1'bz;
	end 	
	end 
	else begin 
		//tag_rs2flr<=5'bzzzzz;
			if((cnt>=0)&&(cnt<=32'hf0000000)) begin
				cnt<=cnt+1;
				if (cnt>=3) //3
						begin
						cnt<=32'hffffffff;
						data_dest_a=rdata1+rdata2;
						tag_rs2flr=mtag;
						res_arr[mtag-8][75]<=0;
						res_arr[mtag-8][37]<=0;
						res_arr[mtag-8][80:76]<='{default:1'bz};;
						res_arr[mtag-8][74:70]<='{default:1'b1};
						res_arr[mtag-8][36:32]<='{default:1'b1};	
						res_arr[mtag-8][69:38]<='{default:1'bz};
						res_arr[mtag-8][31:0]<='{default:1'bz};									
						rdata1<='{default:1'bz};
						rdata2<='{default:1'bz};			
						id_dest_rs2flr<='{default:1'bz};	
//---------------------------------	
				end 	
			end
			
	if(cnt>=32'hf0000000)begin
			data_dest_a='{default:1'b1};	
	   for(reg [4:0] nr=0;nr<=7;nr++)begin 
		   if ((res_arr[nr][75]==1) &&(res_arr[nr][37]==1) )begin 
			 if ((res_arr[nr][69:38]>=0) &&(res_arr[nr][31:0]>=0) )begin 
				rdata1<=res_arr[nr][69:38];
				rdata2<=res_arr[nr][31:0];					
				mtag=nr+8;//加法器的index加8，乘法器的index不用加 
				/*res_arr[nr][75]<=0;
				res_arr[nr][37]<=0;				
				res_arr[nr][80:76]<='{default:1'bz};;
				res_arr[nr][74:70]<='{default:1'b1};
				res_arr[nr][36:32]<='{default:1'b1};		
				res_arr[nr][69:38]<='{default:1'bz};
				res_arr[nr][31:0]<='{default:1'bz};*/												
				//tag_rs2flr=nr+8;
	            cnt<=0; 	
				//			id_dest_rs2flr=id_dest_flr2rs;	
				break;
				end
			end
		end
	end 
	for(integer nr=0;nr<=7;nr++)begin //方便调试，不满8位给8位
		arr[nr][31:0]=res_arr[nr][31:0];  //flr_data2
		arr[nr][36:32]=res_arr[nr][36:32];//tag[39:32]
		arr[nr][39:37]='{default:res_arr[nr][36]};   //tag
		arr[nr][40]=res_arr[nr][37];      //v[47:40]
		arr[nr][47:41]='{default:1'b0};   //v
		
		arr[nr][79:48]=res_arr[nr][69:38];//flr_data1
		arr[nr][84:80]=res_arr[nr][74:70];//tag[87:70]
	  arr[nr][87:85]='{default:res_arr[nr][74]};	   //tag
		arr[nr][88]=res_arr[nr][75];      //v  [95:88]
		arr[nr][95:89]='{default:1'b0};	  //v
		
		arr[nr][100:96]=res_arr[nr][80:76];//destid[102:96]
		arr[nr][102:100]='{default:1'b0};		
	end 
	  arr[0][31:0]=res_arr[0][31:0];
  end 	
		
	end  
endmodule
module mul(clk,rst,mul_busy,
tag_rs2mul,data1,data2,
tag_mul2flr,data_mul2flr);
input wire rst,clk;
inout wire mul_busy;
input wire [4:0] tag_rs2mul;
input wire [31:0] data1,data2;
output reg [31:0] data_mul2flr;
output reg [4:0] tag_mul2flr;
reg [31:0] cnt;
reg r_mul_busy;
reg en_mul;
reg [31:0] rdata1,rdata2,mtag;
bufif1 mul_busy_buf (mul_busy,r_mul_busy,en_mul);
 always @(mul_busy) begin 
end
 always @(rst,clk) begin 
	if (rst==1) begin 
	cnt=0;
	r_mul_busy<=0;
	en_mul=0;
	end 
	else begin 
	
		if (clk==1) begin 
 
            if(mul_busy==1) begin
				if(cnt==0) begin
				rdata1<=data1;
				rdata2<=data2;
				//mtag<=tag_rs2mul;
				end
				cnt<=cnt+1;
				if (cnt==3) begin 
				cnt<=0;
				en_mul=1;
				r_mul_busy=0;
				data_mul2flr<=rdata1*rdata2;
				//tag_mul2flr<=mtag;
				end 
		    end
			else begin 
				en_mul=0;
				r_mul_busy=0;
			     end 
		end 
	end 
end
endmodule 

module add(clk,rst,add_busy,
tag_rs2add,data1,data2,
tag_add2flr,data_add2flr);
input wire rst,clk;
inout reg add_busy;
output reg [4:0] tag_add2flr;
input wire [31:0] data1,data2;
output reg [31:0] data_add2flr;
input wire [4:0] tag_rs2add;
reg [31:0] cnt;
reg r_add_busy;
reg en_add;
reg [31:0] rdata1,rdata2;
reg [4:0] mtag;
bufif1 add_busy_buf (add_busy,r_add_busy,en_add);
 always @(rst,clk) begin 
	if (rst==1) begin 
	cnt=0;
	en_add=0;
	end 
	else begin 
		if (clk==1) begin 
		en_add=0;
		if(add_busy==1) begin
		if (cnt==0) begin
		rdata1<=data1;
		rdata2<=data2;
		mtag<=tag_rs2add;
		end
			cnt<=cnt+1;
			if (cnt==3) begin 
			cnt<=0;
			en_add=1;
			r_add_busy=0;
			data_add2flr<=rdata1+rdata2;
			tag_add2flr <=mtag;
			end 
		end
		end 
	end 
end	
endmodule 	
