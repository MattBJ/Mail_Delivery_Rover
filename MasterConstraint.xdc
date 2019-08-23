 ## remaining configuration required:
 ## IRsignal, whisker, freq_confirm (?)

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## input 1 pin on H-Bridge in the following order:
set_property PACKAGE_PIN J1 [get_ports {pattern[0]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {pattern[0]}]

## input 2 pin on H-Bridge
set_property PACKAGE_PIN L2 [get_ports {pattern[1]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {pattern[1]}]

## input 3 pin on H-Bridge
set_property PACKAGE_PIN J2 [get_ports {pattern[2]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {pattern[2]}]

## input 4 pin on H-Bridge
set_property PACKAGE_PIN G2 [get_ports {pattern[3]}]
    set_property IOSTANDARD LVCMOS33 [get_ports {pattern[3]}]

## enableA pin on H-Bridge
set_property PACKAGE_PIN H1 [get_ports enA]
    set_property IOSTANDARD LVCMOS33 [get_ports {enA}]

## enableB pin on H-Bridge
set_property PACKAGE_PIN K2 [get_ports enB]
    set_property IOSTANDARD LVCMOS33 [get_ports {enB}]

## 3 led's for frequency. (from led 0 to led 2) --> now for showing what state in
set_property PACKAGE_PIN U16 [get_ports {state_led[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {state_led[0]}]
## does not turn off
set_property PACKAGE_PIN E19 [get_ports {state_led[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {state_led[1]}]
	
set_property PACKAGE_PIN U19 [get_ports {state_led[2]}]					
    set_property IOSTANDARD LVCMOS33 [get_ports {state_led[2]}]
## does not turn off
set_property PACKAGE_PIN V19 [get_ports {start_stop[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {start_stop[0]}]
	
set_property PACKAGE_PIN W18 [get_ports {start_stop[1]}]					
    set_property IOSTANDARD LVCMOS33 [get_ports {start_stop[1]}]
    
 ## Mail Delivery
 ## L1, P1, N3
 ## 1 = 10
 ## 2 = 100
 ## 3 = 1k
 
 ## 10 Hz
 set_property PACKAGE_PIN L1 [get_ports {Hzled[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Hzled[0]}]
## 100
set_property PACKAGE_PIN P1 [get_ports {Hzled[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {Hzled[1]}]

## LED3 = freq_confirm output that must be tied
##set_property PACKAGE_PIN V19 [get_ports {freq_confirm}]					
##    set_property IOSTANDARD LVCMOS33 [get_ports {freq_confirm}]

## Turn on LED5 LED1 = left freq, led 2 = right freq
set_property PACKAGE_PIN U15 [get_ports {LED1}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED1}]

## Turning on LED6 to signify the right IPS sensor
set_property PACKAGE_PIN U14 [get_ports {LED2}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {LED2}]

## Turning on LED7 to signify the middle IPS sensor
#set_property PACKAGE_PIN V14 [get_ports {LED7}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED7}]
	
## Turning on LED8 to signify the left IPS sensor
#set_property PACKAGE_PIN V13 [get_ports {LED8}]					
#	set_property IOSTANDARD LVCMOS33 [get_ports {LED8}]	

## right prox sensor
set_property PACKAGE_PIN L17 [get_ports {IPS_signal[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {IPS_signal[0]}]

## Right mid prox sensor
set_property PACKAGE_PIN M19 [get_ports {IPS_signal[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {IPS_signal[1]}]

## Left mid prox sensor
set_property PACKAGE_PIN P17 [get_ports {IPS_signal[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {IPS_signal[2]}]

## Left prox sensor
set_property PACKAGE_PIN R18 [get_ports {IPS_signal[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {IPS_signal[3]}]
	
## whisker button
##Buttons   (btnC)
##set_property PACKAGE_PIN U18 [get_ports whisker]					
##    set_property IOSTANDARD LVCMOS33 [get_ports whisker]
    
## PMOD 
## IR circuits input
set_property PACKAGE_PIN P18 [get_ports {IRsignal_R}]				
    set_property IOSTANDARD LVCMOS33 [get_ports {IRsignal_R}]
    
set_property PACKAGE_PIN B16 [get_ports {IRsignal_L}]				
    set_property IOSTANDARD LVCMOS33 [get_ports {IRsignal_L}]


# limit_a
set_property PACKAGE_PIN N17 [get_ports {limit_a}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {limit_a}]
# limit_b
set_property PACKAGE_PIN M18 [get_ports {limit_b}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {limit_b}]

## Using pmod JB
## A14 -- B15 (top beginning over 3)
## in order of 10 Hz drop to 1k Hz drop
set_property PACKAGE_PIN J3 [get_ports {servo_enable[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {servo_enable[0]}]
##Sch name = JB2
set_property PACKAGE_PIN L3 [get_ports {servo_enable[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {servo_enable[1]}]
##Sch name = JB3
set_property PACKAGE_PIN M2 [get_ports {servo_enable[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {servo_enable[2]}]
	
## whisker inputs, JB
##set_property PACKAGE_PIN A14 [get_ports {whisker_R}]					
##	set_property IOSTANDARD LVCMOS33 [get_ports {whisker_R}]
##set_property PACKAGE_PIN A15 [get_ports {whisker_L}]					
##	set_property IOSTANDARD LVCMOS33 [get_ports {whisker_L}]