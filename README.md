# Zedboard_Mandel

![screenshot](https://github.com/delhatch/Zedboard_Mandel/Picture.jpg)

Author

Del Hatch

Theory

The famous Mandelbrot set is a set of points in the complex plane. In essence, what we want to find out is if the iterative function C below will converge to some constant or diverge to infinity.

The function is

C_{n+1} = C_{n}^2 + C_{0}

with the initial condition simply formed by taking the coordinates in the complex plane,

C_{0} = x + iy

If C has not exceeded the threshold value after a predetermined number of iterations, it is assumed that the current x,y location makes the function converge. In this case, plot a non-black pixel at the current location.

** FPGA Implementation

The Verilog code creates the logic necessary to implement the Mandelbrot function for each pixel and create a 640x480 pixel VGA output.

The heart of the implementation is a "pool" of up to 16 (tested) calculation engines. The engines run a state machine operating on Q8.24 integers. Each iteration requires only 4 clock cycles.

Using the Xilinx XC7Z7020 FPGA on the Zedboard, over 16 engines can be instantiated. See the performance metrics below.

The module "coor_gen.v" generates the x,y coordinate pairs, and feeds them to engines as they become ready.

The module "Engine2VGA.v" operates on engines that have a result available. This module creates the signals required to write that engine's result into the proper location in the VGA frame buffer created from dual-port Block Memory RAM.

** VGA Generator

The Zedboard documentation does not provide a lot of support for using the VGA port. I hope this project will be useful to others wanting to use the VGA port on their Zedboard.

For this project, I used the module "VGA_Controller.v" code unmodified from how I used it in a previous project, "Pure_Mandel" (for the Altera DE2-115 board). Because the Zedboard only uses a 4-bit DAC (resistor ladder), I padded the 4-bit RGB inputs to the VGA_Controller.v module up to 10 bits, as it expects.

In the file "VGA.v" you can see that I use a 12 bit x 307,200 deep true-dual-port Block Memory created using the Xilinx IP generator. This is the frame buffer for the VGA display. Any values written into the A port of this memory (by RTL, no the ARM core in this project) will show up on the VGA display. The B port is used by VGA_Controller to create the VGA waveform/display.

** Performance

As more engines are instantiated, the image frame rate increases. To change the number of engines, modify mandel_constants.vh so that NUM_PROC is whatever is desired. I tested 4 to 16 succesfully.

9 engines -> 12.8 frames per second. (Engines running at 90 MHz.)

16 engines -> 18.6 frames per second. (Engines running at 80 MHz.)


** Improvements

There are a few areas where improvements are possible:

1) I think it is possible to reduce the number of multiplications in the engine algorithm. This could allow for faster calculations.

2) With 10 engines, all of 220 of the DSP blocks are used, so if any reductions are possible here it would allow for more engines to be instantiated (running at the highest clock rate possible).

3) It would be interesting to implement the ability to use the Zedboard buttons to zoom in on the mandelbrot image.

4) Coloring improvements. There are various coloring algorithms that would be an improvement. My coloring algorithm is in VGA.v.




