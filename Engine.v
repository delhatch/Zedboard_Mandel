// Calculating engine. Executes the mandelbrot algorithm.

`include "mandel_constants.vh"

module Engine (
   input [`E_ADDR_WIDTH:0] my_addr,
	input [`E_ADDR_WIDTH:0] engine_addr,
	input [82:0] in_word, // 10 bits x screen coor, 9 bits y screen coor, x coor in Q8.15, y coor in Q8.15.
	input latch_en,             // also indicates "GO" (assuming the address matches)
	input eRST,
	input Engine_CLK,
	input req_ack,              // enables portions of the latched in_word onto the out_word bus.
	output [26:0] out_word,     // tri-state bus. 10 bits of x, 9 bits of y, 8 bits of iterations.
	output reg available,
	output reg service_req
);

localparam	state_a = 3'b000,
				state_b = 3'b001,
				state_c = 3'b010,
				state_d = 3'b011,
				state_e = 3'b100,
				state_f = 3'b101,
				state_g = 3'b110;

// Wire declarations
reg [2:0] state = 3'b000;
reg signed [31:0] NewRe, OldRe, NewIm, OldIm;
reg signed [31:0] temp5, temp6;
reg signed [63:0] temp1, temp2, temp3, temp4;
reg [15:0] ItrCounter;  // Numer of iterations completed w/o escaping
reg [82:0] latched_word;
reg greater;
wire [31:0] eRegRe, eRegIm;
wire [9:0] x_coor;
wire [8:0] y_coor;
wire address_match;

assign x_coor = latched_word[82:73];
assign y_coor = latched_word[72:64];
assign eRegRe = latched_word[63:32];
assign eRegIm = latched_word[31:0];

// Tri-state output. All engines share this bus to place results onto. Goes into frame buffer RAM.
assign out_word = req_ack ? {x_coor, y_coor, ItrCounter[7:0]} : 27'hzzzzzzz;
// The Coor_gen block (generator of coordinates) is signalling it has new coordinates for me.
assign address_match = (engine_addr == my_addr) ? 1'b1 : 1'b0;

// State machine ------------------------------------------------
always @ ( posedge Engine_CLK or posedge eRST ) begin
   if ( eRST ) begin
     state <= state_a;
	  available <= 1'b1;   // Signal that this engine is available.
	  end
	else
	case( state )
	   state_a : begin
						NewRe <= 0;
						OldRe <= 0;
						NewIm <= 0;
						OldIm <= 0;
						ItrCounter <= 0;
						service_req <= 0;    // No result yet.
						// Stay here until address matches and latch_en = 1.
						if( (address_match == 1'b1) && (latch_en == 1'b1) ) begin
						   state <= state_b;
							latched_word <= in_word;
							available <= 1'b0;  // Signal that this engine is now busy.
							end
						else begin
						   available <= 1'b1;   // Signal that this engine is available.
							state <= state_a;
					      end
						end
		
		state_b : begin
						OldRe <= NewRe;
						OldIm <= NewIm;
						state <= state_c;
					 end
		
		state_c : begin    // This state does nothing but give the combinatorial section time
                         //    to finish. Psuedo-pipeline. Keeps max engine clock high.
                   temp1 = (OldRe * OldRe)>>>24;
                   temp2 = (OldIm * OldIm)>>>24;
                   temp5 <= temp1 - temp2 + eRegRe;
                   temp4 = (OldRe * OldIm)>>>24;
                   temp6 <= (temp4 << 1) + eRegIm;   // ( 2 * temp4 )
						 state <= state_d;
					 end

		state_d : begin
      	          temp1 = ((temp5 * temp5) >>> 24);
                   temp2 = ((temp6 * temp6) >>> 24);
                   greater = ( (temp1 + temp2) > 32'h04000000 ) ? 1'b1 : 1'b0;
                   NewRe <= temp5;
						 NewIm <= temp6;
						 if( greater == 1'b1  ) begin  // done. point not in mandelbrot set.
							 state <= state_f;
							 end
						 else if( (ItrCounter + 1) == `MAX_ITERATIONS ) state <= state_f;
                   else begin
							    ItrCounter <= ItrCounter + 1;
							    state <= state_b;
							   end
					  end
					 
		state_f : begin       // hold here until we get an ack signal
		            service_req <= 1'b1;
		            if( ~req_ack ) state <= state_f;
		            else begin
                     service_req <= 1'b0;  // Am now being serviced. I can stop asking for service.
                     state <= state_g;
                     end
		          end
		          
      state_g : begin		// hold here until req_ack falls and
                        // coord gen is ready to assign a new coordinate.
						if( (req_ack) || (latch_en) ) state <= state_g;
						else begin
						   available <= 1'b1;   // Results have been latched. Signal that this engine is now available.
						   state <= state_a;
						end
				  end
					     				 
		default : state <= state_a;
		
	endcase
end     // end of state logic

/*
always @(*) begin  // Mandelbrot complex math routine.
   temp1 = (OldRe * OldRe)>>>24;
   temp2 = (OldIm * OldIm)>>>24;
   temp5 = temp1 - temp2 + eRegRe;
   temp4 = (OldRe * OldIm)>>>24;
   temp6 = (temp4 << 1) + eRegIm;   // ( 2 * temp4 )
   temp1 = ((temp5 * temp5) >>> 24);
   temp2 = ((temp6 * temp6) >>> 24);
   greater = ( (temp1 + temp2) > 32'h04000000 ) ? 1'b1 : 1'b0;
end
*/

endmodule