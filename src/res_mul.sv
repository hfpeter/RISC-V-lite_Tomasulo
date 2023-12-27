module reservation_mul (clk,rst,
tag_flr2rs_1,tag_flr2rs_2,
tag_rs2flr,
id_dest_flr2rs,
flr_data1,flr_data2,data_dest_m,id_dest_rs2flr,opcode,tag_a2m
);  
input clk, rst;
input wire [4:0] id_dest_flr2rs,tag_flr2rs_1,tag_flr2rs_2,tag_a2m;
input wire [31:0] flr_data1,flr_data2;
output reg [31:0] data_dest_m;
output reg [4:0] tag_rs2flr;
input wire [5:0] opcode;
reg [4:0] tag_rs2mul;
output reg [4:0] id_dest_rs2flr;
wire mul_busy;
reg r_mul_busy;
wire [31:0] mul2rs_out;
reg gc;
bufif1 g_mul_busy (mul_busy,r_mul_busy,gc);
reg [80:0] res_arr[0:7];//[75:0] res_arr[0:7];//
reg [4:0] nzcnt;
reg [31:0] rdata1,rdata2,cnt;
reg [4:0] mtag,tmp1,tmp2;
reg  [102:0] arr [0:7];//
 always @( id_dest_flr2rs,rst) begin
 if(rst==0)begin
 if((tag_flr2rs_1!=5'b11111)||(tag_flr2rs_2!=5'b11111)||(flr_data1>=0)||(flr_data2>=0))begin
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  (res_arr[n5][80:76]==id_dest_flr2rs)begin 
							tag_rs2flr=n5+16;
					   break;
				   end 
			   end 
				 end
end				 
end				 
 always @(	tag_flr2rs_1,tag_flr2rs_2,rst) 
 //always @(tag_flr2rs_1,tag_flr2rs_2,posedge clk,rst)
  //always @(posedge clk,rst)
	begin: tag_loop
if(rst==0)begin
		if ((tag_flr2rs_1!=5'b11111)) begin
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  ((res_arr[n5][75]==0)&&(res_arr[n5][74:70]==(tag_flr2rs_2)&&(tag_flr2rs_2!=5'b11111)&&(flr_data1>=0)))begin 
					  res_arr[n5][74:70]=5'b11111;
					  res_arr[n5][69:38]=flr_data1;
						res_arr[n5][75]=1;		
					  // break;
				   end 
			   end    
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  ((res_arr[n5][37]==0)&&(res_arr[n5][36:32]==(tag_flr2rs_1)&&(tag_flr2rs_1!=5'b11111)&&(flr_data2>=0)))begin 
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
						if (  (tag_flr2rs_1!=5'b11111)&&(tag_flr2rs_2!=5'b11111) ) begin//if both operands are not available 
								for(integer n5=0;n5<=7;n5++)begin 
										if (tag_flr2rs_2==res_arr[n5][36:32])
										disable tag_loop;
										if (tag_flr2rs_1==res_arr[n5][74:70])
										disable tag_loop;								
										if  ((res_arr[n5][37]==0)&&(res_arr[n5][75]==0))begin 
											res_arr[n5][80:76]=id_dest_flr2rs;   
											res_arr[n5][74:70]=tag_flr2rs_1;	
											res_arr[n5][36:32]=tag_flr2rs_2;		
											tag_rs2flr=n5+16;	
											id_dest_rs2flr=id_dest_flr2rs;
											disable tag_loop;
											break;
										end 
								end
						end 		
					end
		if ((tag_flr2rs_1!=5'b11111)&&(tag_flr2rs_2==5'b11111)) begin//this if following is 1 of operand available
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  ((res_arr[n5][75]==0)&&(res_arr[n5][74:70]==(tag_flr2rs_2 ))&&(flr_data1>=0))begin 
							res_arr[n5][74:70]=5'b11111;
							res_arr[n5][69:38]=flr_data1;
							res_arr[n5][75]=1;// rs flag 1 is data valid, rs tag 11111 is data valid 
							res_arr[n5][36:32]=n5+16;	
							tag_rs2flr=n5+16;		
							res_arr[n5][80:76]=id_dest_flr2rs;
							id_dest_rs2flr=id_dest_flr2rs;								
							disable tag_loop;
							break;
				   end 
			   end 
		end   
		if ((tag_flr2rs_2!=5'b11111)&&(tag_flr2rs_1==5'b11111)) begin//this if following is 1 of operand available
			   for(integer n5=0;n5<=7;n5++)begin 
				   if  ((res_arr[n5][37]==0)&&(res_arr[n5][36:32]==(tag_flr2rs_1 ))&&(flr_data2>=0))begin 
							res_arr[n5][36:32]=5'b11111;
							res_arr[n5][31:0]=flr_data2;   
							res_arr[n5][37]=1;	
							res_arr[n5][74:70]=n5+16;	
							tag_rs2flr=n5+16;			
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
if(rst==0)	begin		 
    if ((flr_data1>=0)&&((flr_data2>=0))) begin 	
				for(integer n=0;n<=7;n++)begin 
						if((res_arr[n][37]==0)&&((tag_flr2rs_2 )===res_arr[n][36:32])&&(tag_flr2rs_1!=5'b11111)) begin
						//from ALU to RS
							res_arr[n][36:32]=5'b11111;
							res_arr[n][31:30]=flr_data1;
							res_arr[n][37]=1;		
							//disable data_loop;
							//break;
						end	
						if((res_arr[n][75]==0)&&((tag_flr2rs_1 )==res_arr[n][74:70])&&(tag_flr2rs_2!=5'b11111))  begin
								res_arr[n][74:70]=5'b11111;
								res_arr[n][69:38]=flr_data2;   
								res_arr[n][75]=1;							
								disable data_loop;
						end	
					if ((res_arr[n][75]==0)&&(res_arr[n][37]==0)&&(5'b11111==res_arr[n][74:70])&&(5'b11111==res_arr[n][36:32])) begin 
						if((tag_flr2rs_1==5'b11111)&&(tag_flr2rs_2==5'b11111))begin
								res_arr[n][75]=1;
								res_arr[n][37]=1; 
								res_arr[n][80:76]=id_dest_flr2rs;
								id_dest_rs2flr=id_dest_flr2rs;	
								//id_dest_rs2flr=res_arr[n][80:76];
								res_arr[n][69:38]=flr_data1;
								res_arr[n][31:0]=flr_data2;						
								tag_rs2flr=n+16;		
								disable data_loop;
							break;
						end
					end 
				end 		
		end				 
				if ((flr_data1>=0)) begin 
				for(integer n=0;n<=7;n++)begin 	
					if (tag_flr2rs_2==res_arr[n][36:32])
					disable data_loop;					
					if ((res_arr[n][75]==0)&&(res_arr[n][37]==0)&&(5'b11111==res_arr[n][36:32])&&(5'b11111==res_arr[n][74:70])) begin 
					if(tag_flr2rs_1==5'b11111)begin					
						res_arr[n][75]=1;
						res_arr[n][80:76]=id_dest_flr2rs;
						res_arr[n][69:38]=flr_data1;
						id_dest_rs2flr=id_dest_flr2rs;		
						tag_rs2flr=n+16;		//up to here 
						//res_arr[n][36:32]=n;
						res_arr[n][36:32]=tag_flr2rs_2;
						disable data_loop;	
						break;
						end 
					end 
				end //这两个寻址需不需要分开?需要分开，因为从FLR来的不一定有32bit数据，只有tag_flr2rs     
			end
			//else
				if ((flr_data2>=0)) begin 
					for(integer n5=0;n5<=7;n5++)begin 	
							if (tag_flr2rs_1==res_arr[n5][74:70])
							disable data_loop;	
							if  ((res_arr[n5][75]==0)&&(res_arr[n5][37]==0)&&(5'b11111==res_arr[n5][36:32])&&(5'b11111==res_arr[n5][74:70]))begin 
							if(tag_flr2rs_2==5'b11111)begin							
								res_arr[n5][80:76]=id_dest_flr2rs;
								res_arr[n5][37]=1; 
								res_arr[n5][31:0]=flr_data2;		   
								id_dest_rs2flr=id_dest_flr2rs;	
								tag_rs2flr=n5+16;				
								//res_arr[n5][74:70]=n5;			
								res_arr[n5][74:70]=tag_flr2rs_1;
								disable data_loop;
								break;
								end
							end 
					end    	
				end	 
 
end 
 end
 always @(rst,posedge clk) begin //only need posedge sensitive, or, there is duplcated data
	if (rst==1) begin 
	cnt=32'hffffffff;
	tag_rs2flr=5'bzzzzz;
	//tag_rs2flr<=5'bzzzzz;
	res_arr <= '{default:0};
	data_dest_m<=0;
	gc=1;
	nzcnt=0;
    for(integer nr2=0;nr2<=7;nr2++)begin
        res_arr[nr2][36:32]<=5'b11111;
        res_arr[nr2][74:70]<=5'b11111;
    end 	
	end 
	else begin 
	//tag_rs2flr<=5'bzzzzz;
			if((cnt>=0)&&(cnt<=32'hf0000000)) begin
				cnt<=cnt+1;
				if (cnt>=5) begin //模拟乘法器需要7个周期完成
				cnt<=32'hffffffff;
				data_dest_m=rdata1*rdata2;
						tag_rs2flr=mtag;
						res_arr[mtag-16][75]=0;
						res_arr[mtag-16][37]=0;
						res_arr[mtag-8][80:76]='{default:1'bz};;
						res_arr[mtag-16][74:70]='{default:1'b1};
						res_arr[mtag-16][36:32]='{default:1'b1};	
						res_arr[mtag-16][69:38]='{default:1'bz};
						res_arr[mtag-16][31:0]='{default:1'bz};									
						rdata1='{default:1'bz};
						rdata2='{default:1'bz};
						id_dest_rs2flr='{default:1'bz};
//---------------------------------	
				end 	
			end
				
	if(cnt>=32'hf0000000)begin
			data_dest_m='{default:1'b1};		
	   for(reg [4:0] nr=0;nr<=7;nr++)begin 
		   if ((res_arr[nr][75]==1) &&(res_arr[nr][37]==1) )begin 
			 if ((res_arr[nr][69:38]>=0) &&(res_arr[nr][31:0]>=0) )begin 
				rdata1<=res_arr[nr][69:38];
				rdata2<=res_arr[nr][31:0];	
				mtag=nr+16;
				/*res_arr[nr][75]<=0;
				res_arr[nr][37]<=0;				
				res_arr[nr][80:76]<='{default:1'bz};;
				res_arr[nr][74:70]<='{default:1'b1};
				res_arr[nr][36:32]<='{default:1'b1};		
				res_arr[nr][69:38]<='{default:1'bz};
				res_arr[nr][31:0]<='{default:1'bz};*/												
				//tag_rs2flr=nr+16;				
				//id_dest_rs2flr=id_dest_flr2rs;	
	            cnt<=0; 	
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