// mandel_constants.vh

// If we have not included this file before,
// this symbol _mandel_constants_vh_ is not defined.

`ifndef _mandel_constants_vh_
   `define _mandel_constants_vh_

   // Number of mandelbrot engines to instantiate
   `define NUM_PROC 9
   // Number of bits in engine address bus.
   `define E_ADDR_WIDTH $clog2(`NUM_PROC)
   `define MAX_ITERATIONS 255  // Do not exceed 65535. Counting happens in engine.ItrCounter[15:0].
`endif