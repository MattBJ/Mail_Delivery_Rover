`timescale 1ns / 1ps

// Our system is a two slide system, with three shelves for each index card
// This means our rover will have two separate relative distances to deliver to
// ergo, might have to include a slight movement algorithm to make sure mail drops in correct place
			// all dependent on if right side or left side....

// SCRATCH THAT:		--> put each whisker RIGHT BELOW their corresponding slide
//							-in this scenario, we get detection signal and confirmation signal at the EXACT drop location required

module Mail_delivery(
	input clk,
	input [1:0] state, prev_state,
	input [1:0] freq_confirm_L, freq_confirm_R,	// which mail needs to be delivered
	output reg [2:0] servo_enable,	// duty cycled-PWM signals controlled by PWM instantiated module
	output reg Go,	// after delay, tells board to keep going
	output reg [1:0] Hzled
	);

// registers to keep track of each servo duty cycle
reg [17:0] PWM_1k, PWM_100, PWM_10;	// Needs to have the 1500 - 1900 micro second range
reg [26:0] delay = 0;	// delay can hold more than 100 million clock counts (100MHz)

// these constants are the optimum angles at which to hold the cards or drop them

// SUBJECT TO CHANGE DUE TO EXPERIMENTATION/DOCUMENTATION
// all 7-bit constants to concatinate
localparam stationary 	= 18'd150000; 	// 1,500 microseconds = 1,500,000 nanoseconds ('NEUTRAL' position) divided by 10 nanosecond period (posedge) = 150,000 count increments
localparam right_side 	= 18'd205000;	// 1,900 microseconds = 1,900,000 nanoseconds divided by 10 nanosecond period (posedge) = 190,000 count increments
//localparam left_side 	= 18'd0;		// full counterclockwise
localparam left_side 	= 18'd100000;	// made it a little less steep

// all 2-bit variables to keep case statement simple
localparam none			= 2'b00;
localparam Hz10 		= 2'b01;
localparam Hz100 		= 2'b10;
localparam Hz1k 		= 2'b11;

localparam one_second	= 100000000;	// 100 million clock ticks
// END OF CONSTANTS

// module instantiations
//ServoPWM	SPWM0 (
//	.clk(clk),
//	.PWM_1k(PWM_1k), .PWM_100(PWM_100), .PWM_10(PWM_10),
//		// IO
//	.servo_enable(servo_enable)
//	);
// end of module instantiation

initial begin
	{PWM_1k, PWM_100, PWM_10} = stationary;
end

reg [20:0] count = 0;
parameter count_max = 2000000;  // 20 miliseconds


always@(posedge clk) begin

    count <= count + 1;
    
	if(state == 2) begin
		
		Hzled = freq_confirm_R;
		
	    delay <= (prev_state == 1)? one_second :
	             (delay)? delay - 1 : 0;
		Go <= (delay)? 0 : 1; // once delay is finished, go to next state
	end
	
	//else begin
	//	{PWM_1k, PWM_100, PWM_10} = {stationary, stationary, stationary};
	//end
	
	if(count == count_max) begin                 // count_max isn't chnged anywhere
	   count <= 0;
	end
	else begin
		  servo_enable[0] <= (PWM_10 > count)? 1 : 0;
		  servo_enable[1] <= (PWM_100 > count)? 1 : 0;
		  servo_enable[2] <= (PWM_1k > count)? 1 : 0;	
        end
    end


always@(*) begin // combinational state conditional ckt
	// Mail delivery state
	if(state == 2) begin
		case({freq_confirm_L, freq_confirm_R}) 	// 4-bit possibility
		//	{LEFT,RIGHT}
			{none,Hz10}:
				PWM_10 = right_side;
			{none,Hz100}:
				PWM_100 = right_side;
			{none,Hz1k}:
				PWM_1k = right_side;
			{Hz100,Hz10}:
				{PWM_100,PWM_10} = {left_side,right_side};
			{Hz1k,Hz10}:
				{PWM_1k,PWM_10} = {left_side,right_side};
			{Hz10,Hz100}:
				{PWM_10,PWM_100} = {left_side,right_side};
			{Hz1k,Hz100}:
				{PWM_1k,PWM_100} = {left_side,right_side};
			{Hz10,Hz1k}:
				{PWM_10,PWM_1k} = {left_side,right_side};
			{Hz100,Hz1k}:
				{PWM_100,PWM_1k} = {left_side,right_side};
			{Hz10,none}:
				PWM_10 = left_side;
			{Hz100,none}:
				PWM_100 = left_side;
			{Hz1k,none}:
				PWM_1k = left_side;
		  default:
		      {PWM_10, PWM_100, PWM_1k} = {stationary, stationary, stationary};
		endcase
	end
	// otherwise, everything back to original positions
	else begin
		{PWM_1k, PWM_100, PWM_10} = {stationary, stationary, stationary};
	end
end


endmodule