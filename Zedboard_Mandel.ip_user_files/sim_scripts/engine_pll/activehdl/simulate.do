onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+engine_pll -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.engine_pll xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {engine_pll.udo}

run -all

endsim

quit -force
