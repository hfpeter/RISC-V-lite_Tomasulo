module mem_wrap_fake #(
		   parameter CONTENT_TYPE,
		   parameter tco,
		   parameter tpd
   )  (
     input logic  CLK ,
     input logic  RSTn ,
     output logic PROC_REQ ,
     input logic MEM_RDY ,
     output logic ADDR ,
     output logic WWE ,
     output logic WWDATA ,
     input logic RDATA ,
     input logic VALID ,
     input logic VALID 
   );
   
sram_32_1024_freepdk45 usram(
   CLK,VALID,WWE,ADDR,RDATA,WWDATA
);
   assign CONTENT_TYPE=0;
  always @(posedge CLK)
  begin
   tco=1 ns;
   tpd=1 ns;
  end

endmodule 	
   