// This module runs through each x,y screen pixel (640 x 480) and calculates
//   the associated values in x + iy mandelbrot space.
// It then passes these values to any calculating engine that is available to run the
//   algorithm.

`include "mandel_constants.vh"

module Coor_gen 
#( parameter C_ADDR_WIDTH = 4 )
(
	input cclk,
	input creset,
	input [`NUM_PROC-1:0] cdones,  // one-hot.
	output clatch_en,
	output reg [C_ADDR_WIDTH-1:0] cengine_addr,  // address of the engine the latch is intended for.
	output [82:0] cword2engines,    // x,y in int and fractional integer. To engines.
	output frame    // pulses at the start, and at the end, of a frame.
);

localparam step_size = 32'h02666666; // This is 0.0046875 (the step size) multiplied by 2**9. Q8.15.

wire [9:0] x_value;
wire [8:0] y_value;
wire y_max_tick;
wire null_wire;

reg signed [63:0] temp1, temp2, temp3, temp4, temp5, temp6;
reg signed [31:0] outx, outy;
wire none_done;

assign none_done = ~( |(cdones) );  // high if all engines are busy (none are finished calculating yet)

always @ ( x_value ) begin
   temp2 = x_value <<< 15; // would be <<< 24 to align decimal points, but then divide by 2**9.
   temp3 = ((temp2 * step_size)>>>24);
   outx = temp3 - 32'h02000000;
end

always @ ( y_value ) begin
   temp5 = y_value <<< 15;
   temp6 = (temp5 * step_size)>>>24;
	outy = 32'h01200000 - temp6;
end

assign cword2engines = { x_value, y_value, outx, outy };

integer j;
always @ ( negedge cclk )
   for( j=`NUM_PROC-1; j>=0; j=j-1 ) 
      if( cdones[j] == 1 ) cengine_addr = j;

assign clatch_en = ~none_done;

Mod_counter #( .N(10), .M(640) ) x_cntr (   // 10 bit counter, counts 0 to 639.
		.clk( cclk ),
		.clk_en( y_max_tick ),
		.pause( none_done ),
		.reset( creset ),
		.q( x_value ),
		.max_tick( null_wire )
);

assign frame = ((x_value <100) ) ? 1'b1 : 1'b0;   // Pulses once per frame. To measure frame reate.

Mod_counter #( .N(9), .M(480) ) y_cntr  (   // 9 bit counter, counts 0 to 479.
		.clk( cclk ),
		.clk_en( 1'b1 ),
		.pause( none_done ),
		.reset( creset ),
		.q( y_value ),
		.max_tick( y_max_tick )
);

endmodule