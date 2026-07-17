#set clk
#set_property PACKAGE_PIN H9 [get_ports clk_p]
#set_property PACKAGE_PIN G9 [get_ports clk_n]
#set_property IOSTANDARD LVDS [get_ports clk_p]
#set_property IOSTANDARD LVDS [get_ports clk_n]
#create_clock -period 5.0 [get_ports clk_p]
##set reset_n
#set_property PACKAGE_PIN K15 [get_ports reset_n]   ;# GPIO_SW_CENTER
#set_property IOSTANDARD LVCMOS15 [get_ports reset_n]

# for ZC702
## Clock pins
set_property PACKAGE_PIN C19  [get_ports sys_clk_n]
set_property PACKAGE_PIN D18  [get_ports sys_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports sys_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports sys_clk_n]

## Reset button (center button, active high)
set_property PACKAGE_PIN G19 [get_ports reset]
set_property IOSTANDARD LVCMOS25 [get_ports reset]