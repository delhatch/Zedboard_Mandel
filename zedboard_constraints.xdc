# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y9 [get_ports {GCLK}];  # "GCLK"
# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
# ---------------------------------------------------------------------------- 
#set_property PACKAGE_PIN P16 [get_ports {fire}];  # "BTNC"
set_property PACKAGE_PIN R16 [get_ports {rst}];  # "BTND"
#set_property PACKAGE_PIN N15 [get_ports {btnL}];  # "BTNL"
#set_property PACKAGE_PIN R18 [get_ports {btnR}];  # "BTNR"
#set_property PACKAGE_PIN T18 [get_ports {startbtn}];  # "BTNU"
# ----------------------------------------------------------------------------
# VGA Output - Bank 33
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y21  [get_ports {VGA_B[0]}];  # "VGA-B1"
set_property PACKAGE_PIN Y20  [get_ports {VGA_B[1]}];  # "VGA-B2"
set_property PACKAGE_PIN AB20 [get_ports {VGA_B[2]}];  # "VGA-B3"
set_property PACKAGE_PIN AB19 [get_ports {VGA_B[3]}];  # "VGA-B4"
set_property PACKAGE_PIN AB22 [get_ports {VGA_G[0]}];  # "VGA-G1"
set_property PACKAGE_PIN AA22 [get_ports {VGA_G[1]}];  # "VGA-G2"
set_property PACKAGE_PIN AB21 [get_ports {VGA_G[2]}];  # "VGA-G3"
set_property PACKAGE_PIN AA21 [get_ports {VGA_G[3]}];  # "VGA-G4"
set_property PACKAGE_PIN AA19 [get_ports {VGA_hSync}];  # "VGA-HS"
set_property PACKAGE_PIN V20  [get_ports {VGA_R[0]}];  # "VGA-R1"
set_property PACKAGE_PIN U20  [get_ports {VGA_R[1]}];  # "VGA-R2"
set_property PACKAGE_PIN V19  [get_ports {VGA_R[2]}];  # "VGA-R3"
set_property PACKAGE_PIN V18  [get_ports {VGA_R[3]}];  # "VGA-R4"
set_property PACKAGE_PIN Y19  [get_ports {VGA_vSync}];  # "VGA-VS"
# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN T22 [get_ports {LD0}];  # "LD0"


# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
#set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];