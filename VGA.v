// This module creates the VGA waveform.

`include "mandel_constants.vh"

module VGA (
	input [7:0] writedata_iDATA,   // Data going into the dual-port RAM.  // TODO
	input [18:0] address_iADDR,     // 640x480 = 307,200 12-bit locations. 2^19 = 524,288
	input write_iWR_en,
	input iRST_N,
	input clk_iCLK,		//	Host Clock for writes into video memory.
	//	Export Side
	output [3:0] export_VGA_R,
	output [3:0] export_VGA_G,
	output [3:0] export_VGA_B,
	output export_VGA_HS,
	output export_VGA_VS,
	input  iCLK_25	    // VGA pixel clock in.
);

wire [18:0] mVGA_ADDR;   // Between the VGA_Controller and the dual-port memory.
wire [9:0] L_VGA_R, L_VGA_G, L_VGA_B;  // Output of VGA_Controller is 10-bit video.
wire [7:0] index;
wire [7:0] b_data; 
wire [7:0] g_data;  
wire [7:0] r_data;
wire [9:0] mMouse_R;
wire [9:0] mMouse_G;
wire [9:0] mMouse_B;
wire [11:0] bgr_data_raw;
reg [11:0] bgr_data;
reg [11:0] colorized;

assign mMouse_R = {r_data,2'b00};  // Pad the 8-bit color data to 10 bits for the VGA_Controller.
assign mMouse_G = {g_data,2'b00};
assign mMouse_B = {b_data,2'b00};
assign export_VGA_R = L_VGA_R[5:2];  // DE2 VGA DAC is an 4-bit resistor ladder
assign export_VGA_G = L_VGA_G[5:2];
assign export_VGA_B = L_VGA_B[5:2];

VGA_Controller		u0	(	//	Host Side
								.iCursor_RGB_EN( 4'b0111 ),  // Disable cursor. Enable r,g,b outputs.
								.iCursor_X( 10'd100 ),
								.iCursor_Y( 10'd100 ),
								.iCursor_R( 10'b11_1111_1111 ),
								.iCursor_G( 10'b11_1111_1111 ),
								.iCursor_B( 10'b11_1111_1111 ),							
								.oAddress( mVGA_ADDR ),
	/* Video in */				.iRed ( mMouse_R ),     // 10-bit video input
								.iGreen ( mMouse_G ),
								.iBlue ( mMouse_B ),
								//	VGA Side
	/* Video out */				.oVGA_R( L_VGA_R ),     // 10-bit video output
								.oVGA_G( L_VGA_G ),
								.oVGA_B( L_VGA_B ),
								.oVGA_H_SYNC( export_VGA_HS ),
								.oVGA_V_SYNC( export_VGA_VS ),
								//.oVGA_SYNC( export_VGA_SYNC ),
								//.oVGA_BLANK( export_VGA_BLANK ),
								//.oVGA_CLOCK( export_VGA_CLK ),    // Is simply assigned ~iCLK_25 in this module.
								//	Control Signal
								.iCLK_25( iCLK_25 ),
								.iRST_N( iRST_N )
							);
always @ ( writedata_iDATA )
   if( writedata_iDATA<16 ) colorized = {8'b0000_0000, writedata_iDATA[3:0] };
   else if( writedata_iDATA<32 ) colorized = {4'b0000, writedata_iDATA[3:0], 4'b1111 };
   else if( writedata_iDATA<48 ) colorized = {4'b0000, 4'b1111, (15 - writedata_iDATA[3:0]) };
   else if( writedata_iDATA<64 ) colorized = {writedata_iDATA[3:0], 4'b1111, 4'b0000 };
   else if( writedata_iDATA<80 ) colorized = {8'b1111_1111, writedata_iDATA[3:0] };
   else if( writedata_iDATA<254 ) colorized = 12'hfff;
   else colorized = 12'h000;

// Holds the image. Each 8-bit value refers to a 24-bit color in the look-up table.
my_img_data img_data_inst (
   // Read side
   .clkb( ~iCLK_25 ),      // Same signal as "export_VGA_CLK"
   .web( 1'b0 ),           // Never write. VGA logic only reads pixel values.
   .addrb( mVGA_ADDR ),
   .doutb( bgr_data_raw ),
   .dinb( 12'h000 ),          // Will not ever use this port for writing.
   // Write side
   .clka( clk_iCLK ),     // From the Engine2VGA interface.
   .ena( write_iWR_en ),
   .wea( write_iWR_en ),// From the Engine2VGA interface.
   .addra( address_iADDR ),  // From the Engine2VGA interface.
   .dina( colorized )  //     // From the Engine2VGA interface, then through the colorization algorithm, above.
   //.douta()                // Leave output data un-connected. Never reads from this port.
);
//will latch valid data at falling edge;
always @( posedge iCLK_25 ) 
   bgr_data <= bgr_data_raw;

assign b_data = {3'b000, bgr_data[3:0]};
assign g_data = {3'b000, bgr_data[7:4]};
assign r_data = {3'b000, bgr_data[11:8]};
//assign b_data = bgr_data[23:16];
//assign g_data = bgr_data[15:8];
//assign r_data = bgr_data[7:0];

endmodule

