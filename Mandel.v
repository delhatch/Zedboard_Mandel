// Creates VGA mandelbrot w/ pure logic. No Nios.
// Note: With 12 engines, the max clock freq. is around 92 MHz with DE2-115 (EP4CE115F29C7).
//       It can calculate ~20 frames per second.
//    With only 4 engines, fmax is ~100 MHz. 5.04 frames per second.

`include "mandel_constants.vh"

module Mandel (
	input rst,
	output LD0,     // Pulse once per frame. Used with frequency counter to measure frame rate.
	input GCLK,      // Zedboard input clock (GCLK on Y9) at 100 MHz.
   //////// VGA //////////
	output [3:0] VGA_B, // Blue
	output [3:0] VGA_G,
	output VGA_hSync,
	output [3:0] VGA_R,
	output VGA_vSync
);

wire top_reset;    // Tied to KEY[0]
wire [`NUM_PROC-1:0] dones;
wire latch, top_wr_enable, engine_clock, VGA_clock;
wire [`E_ADDR_WIDTH-1:0] top_engine_addr;
wire [82:0] word;
wire [18:0] ram_address;
wire [7:0] ram_data;
wire [`NUM_PROC-1:0]req_ack_bus;
wire [`NUM_PROC-1:0] top_eng_req;
wire [26:0] engine_word;
wire top_frame;

assign LD0 = top_frame;
assign ram_address = engine_word[26:17] + ( engine_word[16:8] * 640 ); // x+y*640
assign ram_data = engine_word[7:0];
assign top_reset = rst; //BTND on Zedboard;

Coor_gen #( .C_ADDR_WIDTH(`E_ADDR_WIDTH) ) u1 (
	.cclk( engine_clock ),
	.creset( top_reset ),
	.cdones( dones ),         // Signals indicating an engine is available. One-hot coded.
	.clatch_en( latch ),			// outof. Tells specified engine to latch the word (and go).
	.cengine_addr( top_engine_addr ),  // outof. Addr of an available engine. The one being given work.
	.cword2engines( word ), // outof. {10 bits for x, 9 for y, two x 32 bits of fractional x,y coor.s.}
	.frame( top_frame )
);
//-------  Instantiate the calculating engines -----------------------
genvar i;
generate
   for( i=0; i<`NUM_PROC; i = i+1 )
   begin : eng
      Engine e(
          .my_addr( i ),
          .engine_addr( top_engine_addr ),  // Is coordinate_generator trying to talk to this instance?
          .in_word( word ),   // 82-bit word from coordinator generator.
          .latch_en( latch ), // single latch from coordinator generator to all engines. (eng addr must match)
          .eRST( top_reset ),
          .Engine_CLK( engine_clock ),
          .req_ack( req_ack_bus[i] ),   // Number of this Engine.
          .out_word( engine_word ),    // 27-bit tri-state bus.  Engine's itr results, along with assoc'd x,y.
          .available( dones[i] ),      // output of engine. tells coordinator generator to feed me new coor.s
          .service_req( top_eng_req[i] )  // Tells Engine2VGA that it has a result, ready to go to RAM.
          );
    end
endgenerate
//-------  Done instantiating the engines -----------------------
Engine2VGA u3 (
   .engine_req( top_eng_req ),  // 3:0 Number of engines. one-hot coded.
	.req_ack( req_ack_bus ),     // 3:0 Acknowledge the request. In response, the engine will place it's word on the bus.
	.write_iWR_en( top_wr_enable ),  // outof. Goes to dual-port RAM.
	.clk_iCLK( engine_clock ),
	.reset( top_reset )
);

VGA vpg (
   .writedata_iDATA( ram_data ),   // This comes from part of the tri-state bus coming from the engines
	.address_iADDR( ram_address ),  // This too.
	.write_iWR_en( top_wr_enable ), // comes from Engine2VGA.
	.iRST_N( ~top_reset ),
	.clk_iCLK( engine_clock ),      // clock for the dual-port RAM.
	.export_VGA_R( VGA_R ),         // 4-bit RGB video outputs.
	.export_VGA_G( VGA_G ),
	.export_VGA_B( VGA_B ),
	.export_VGA_HS( VGA_hSync ),
	.export_VGA_VS( VGA_vSync ),
	//.export_VGA_SYNC( VGA_SYNC_N ),
	//.export_VGA_BLANK( VGA_BLANK_N ),
	//.export_VGA_CLK( VGA_CLK ),   // out to the VGA connector
	.iCLK_25( VGA_clock )         // VGA pixel clock in.
);

// Set up Engine PLL. Output c0 is ~100 MHz for the computation engines, depending
//    on the number of engines instantiated. (92 MHz for 12 engines, 100 MHz for four)
engine_pll u2 (
   // Clock out ports
   .clk_out1(engine_clock),     // Calculating engines run at this rate. Started at 10 MHz.
   .clk_out2(VGA_clock),        // VGA pixel clock = 27.125 MHz.
   // Clock in ports
   .clk_in1(GCLK)      // input clk_in1
);

// If an engine is working then light up it's LED. (1->LED = illuminated)
//assign LEDR[`NUM_PROC-1:0] = dones[`NUM_PROC-1:0];

endmodule