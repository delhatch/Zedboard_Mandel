// Gets results from engines that have results, and puts the results
//   into the dual-port VGA RAM.
module Engine2VGA (
	input [`NUM_PROC-1:0] engine_req,    // one-hot coded.
	output reg [`NUM_PROC-1:0] req_ack,  // acknowledge the request. In response, the engine will place it's word on the bus.
	// Dual-port RAM side
	output reg write_iWR_en,
	input clk_iCLK,		//	Host Clock for writes into memory. Is the engine clock.
	input reset
);
 
localparam	state_a = 3'b000,
				state_b = 3'b001,
				state_c = 3'b010,
				state_d = 3'b011;

reg [2:0] state = 0;
reg [`NUM_PROC-1:0] calc_req_ack;  // one-hot. indicates which engine will get ack'd. If zero, nobody asking.

always @ ( posedge clk_iCLK or posedge reset ) begin
   if( reset ) begin
	   state <= state_a;
	   write_iWR_en <= 1'b0;      // Tell RAM that no one needs to write a result into it.
		end
	else
	   case( state )
		   state_a : begin
						   write_iWR_en <= 1'b0;      // Tell RAM no one is writing to it.
						   req_ack <= 0;              // Tell all engines to get off the bus.
						   // Stay here until there is a request for service.
						   state <= ( |(calc_req_ack) ) ? state_b : state_a;
					    end
		
			state_b : begin
		               req_ack <= calc_req_ack;   // Tell the engine it has been selected.
					   	write_iWR_en <= 1'b1;      // Get RAM ready for a write.
					   	state <= state_c;
					    end
		
			state_c : begin
					   	write_iWR_en <= 1'b0;
					   	req_ack <= 0;
					   	state <= state_d;
					    end
		
			state_d : begin   // just wait for the engine to drop it's req line
					   	state <= state_a;
					    end
					    					    
		default : state <= state_a;
	endcase
end

// Look for an engine that has signalled it has a result.
// It will always select the engine with the lowest address, but that priority is arbitrary.
integer j;
always @ ( negedge clk_iCLK )
   for( j=`NUM_PROC-1; j>=0; j=j-1 ) 
	   if( engine_req[j] == 1'b1 ) begin
		   if( j!=(`NUM_PROC-1) ) calc_req_ack = 0;// only select one. clear all others.
		   calc_req_ack[j] = 1'b1;
			end
		else begin 
		   calc_req_ack[j] = 1'b0;
			end
//  The code below works (does the same thing as the loop above), but
//    the code below is not parametized, so should not be used.
/*
always @ ( negedge clk_iCLK )
	casex( engine_req )
		12'bxxxxxxxxxxx1 : calc_req_ack = 12'b000000000001;
		12'bxxxxxxxxxx10 : calc_req_ack = 12'b000000000010;
		12'bxxxxxxxxx100 : calc_req_ack = 12'b000000000100;
		12'bxxxxxxxx1000 : calc_req_ack = 12'b000000001000;
		12'bxxxxxxx10000 : calc_req_ack = 12'b000000010000;
		12'bxxxxxx100000 : calc_req_ack = 12'b000000100000;
		12'bxxxxx1000000 : calc_req_ack = 12'b000001000000;
		12'bxxxx10000000 : calc_req_ack = 12'b000010000000;
		12'bxxx100000000 : calc_req_ack = 12'b000100000000;
		12'bxx1000000000 : calc_req_ack = 12'b001000000000;
		12'bx10000000000 : calc_req_ack = 12'b010000000000;
		12'b100000000000 : calc_req_ack = 12'b100000000000;
		default : calc_req_ack = 12'b000000000000;  // Could do "full_case", but "default" is better form.
	endcase
*/

endmodule