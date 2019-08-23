`timescale 1ns / 1ps

// PWM CODE

// FOR DC MOTOR USE!!!
module PWM(
	input clk,
	input [7:0] PWM_a,  // pwm inputs modify percentage times on/off for enable bits
	input [7:0] PWM_b,	// these inputs decided by state machine / rover_movement module

	output reg enA, // enA/B are on or off based on duty cycles.
	output reg enB	// duty cycles detail what % of time (/second)
					// the signal remains on.
					// 50 % --> [|||||||______], 1 second of time					
	);
	// UPDATE SECTION:
	//	changed count max to 255 so that frequency fluctuates more and should be more of an
	//	average speed than an updatey one

	localparam count_max = 255;	// don't know motor's time period, 255 for simplicity sake
	localparam PWM_max = 255;	// denominator in percentage variable


	reg [8:0] count = 0;	// can go past 100 million integer.
	// reg [8:0] Acount_off = 0;	//determines when PWM signal needs to be off in reference to count
	// reg [8:0] Bcount_off = 0; // NEEDS TO BE 35 BITS TO MULTIPLY 100 MIL * 255
	// reg [8:0] buffer = 0;
	

	always@(posedge clk)	// period (time between posedges) = 10 nanoseconds (100MHz frequency)
		begin // keeps track of counter increments and determines if en
			if(count == count_max)	// reach 100 million tics, set to 0
				count <= 0;
			else begin
				count <= count + 1;	// current time over a second
				
				enA <=  (PWM_a > count)? 1 : 0;
				enB <=  (PWM_b > count)? 1 : 0;
				// these are conditional enable settings.
				// if the count to go off is greater than timer, then signals are on. else off.
				// note, when PWM is updated, the counter doesn't restart. doesn't matter, this
						// miniscule difference shouldn't be noticed
			end
		end
		
endmodule