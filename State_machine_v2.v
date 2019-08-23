`timescale 1ns / 1ps

// presentation state machine --> Controls: -movement module (PWM and direction)
//								  			-IR module (lights up LEDs on board 10, 100, 1kHz)


// UPDATE: removed LED funcionality from IR state, changed freq_confirm from 1 bit to 2, and now both confirms and represents
// 			which mailbox we are at.
//			-by tomorrow, need to deside if instantiating 2 IR_frequency modules or taking care of both sides in 1.
//			-if both in 1, need less variables in state machine but more complicated IR freq module
//			-if two separate instantiations, simpler freq modules, more complicated state machine



module State_Machine (
	input clk,
	//input [1:0] whisker,			// 0 = no detect, 1 = right detect, 2 = left detect, 3 = both detect
	input [3:0] IPS_signal,	// determines rover movement
	input IRsignal_R, IRsignal_L,
	input limit_a, limit_b,
	//input whisker_R, whisker_L, // will have a delay for debouncing
	//output [2:0] HzLED,		--> has been removed since debugging proves the detection works. Keep old code for testing purposes! 
	output enA,				// duty cycle controlled, speed
	output enB,				// duty cycle controlled, speed
	output [3:0] pattern,	// direction control
	output [2:0] servo_enable, 	// 3 servo duty cycled enable outputs
	output reg [2:0] state_led,	// for debugging purposes
	output [1:0] start_stop,		// LED for debugging purposes 
	output reg LED1, LED2,
	output [1:0] Hzled
	);

reg [1:0] state = 0;    	// Movement state vs Frequency state
reg [1:0] prev_state = 0;
reg [1:0] next_state = 0;
reg [1:0] mailbox = 0;
reg [1:0] IR_delay = 0;     // MSB - left side, LSB - right side
wire [1:0] freq_confirm_R;	// switched from output (wire) to just wire
wire [1:0] freq_confirm_L;
wire Go;					// Go signal, tells rover to go back to movement state
wire IR_error_L, IR_error_R;


rover_movement	RM_a(
	.signal(IPS_signal),
	.clk(clk),
	.state(state),
	// IO
	.pattern(pattern),		// enA = 2-bit. enB = 2-bit
	.enA(enA),				// determined by PWM module
	.enB(enB),				// determined by PWM module
	.limit_a(limit_a),
	.limit_b(limit_b),
	.start_stop(start_stop)
	
	);

// two instantiations: only difference is the IRsignal input and frequency confirm (mailbox) variable

IR_frequency	IR_L(
	.clk(clk), 
	.IRsignal(IRsignal_L),
    .state(state),
    // IO
	.freq_confirm(freq_confirm_L),
	.error_flag(IR_error_L)
    );

IR_frequency	IR_R(
	.clk(clk),
	.IRsignal(IRsignal_R),
	.state(state),
	// IO
	.freq_confirm(freq_confirm_R),
	.error_flag(IR_error_R)
	);

Mail_delivery MD(
	.clk(clk),	//clocked
	.state(state),
	.prev_state(prev_state),	// to make the delay
	.freq_confirm_L(freq_confirm_L), .freq_confirm_R(freq_confirm_R),
	// IO
	.servo_enable(servo_enable), .Go(Go),
	.Hzled(Hzled)
	);
	
parameter half_second = 150000000; // 650,000,000 -> 700 MHz
reg [29:0] delay = 0;   // corresponds to IR_delay


always@(posedge clk)	// synchronous update of current state
	begin
		prev_state <= state;
		state <= next_state;
		// delay: upon transitioning to movement state, whiskers will bounce
		//   to prevent this, when going to movement state, will ignore specific whisker
		//   input for arbitrary time
		delay <=  (state == 2 && next_state == 0)? half_second :
		          (delay)? delay - 1 : 0;
	end
/*	STATE MACHINE IDEOLOGY:
		-doesn't matter what the current inputs are, output only depends on state
		-next state depends on current inputs, when clock updates state is changed
	
	MODULES
		Rover_movement
			--> IPS sensor input
			--> Direction/ 'speed' output
			-Depending on 4-bit 'signal' variable, 4-bit 'pattern' determines direction.
			-uses PWM module to change enable A and B's speed depending on state
		IR detection
			--> after whisker press (pressure sensor pmod)
			--> Infrared circuit detection input
			- takes the frequency counted variable and uses ranged conditionals
				to determine which mailbox at (roughly if 10 Hz, 100 Hz, or 1kHz)
	UPDATED STATE MACHINE
		2 states:
			1 - Rover Movement
			2 - Frequency detection	
*/
always@(*)
	begin
	
		case(state)
			0: 	begin 	// Rover Movement state
			         IR_delay = (delay)? IR_delay : 0;
			         state_led = 3'b001;
					 if(IRsignal_L || IRsignal_R)	// only matters in state = 0;
						next_state =(IRsignal_R && IR_delay == 2'b01)? state :
						            (IRsignal_L && IR_delay == 2'b10)? state : 1;
					 else
						next_state = state;
				end
				
			1: 	begin 	// Frequency detection state
			        // rover stopped moving, shouldn't be a problem
			        next_state = (delay)? 0 : next_state;
			        
					state_led = 3'b010;
					if(freq_confirm_R || freq_confirm_L) begin// confirmation will exist as a 0-3.
										// 0 = unconfirmed, 1-3 = 10 Hz - 1000 Hz
     					IR_delay = (freq_confirm_R)? 2'b01 : 2'b10;
						next_state = 2;	// ready to deliver mail
						end
					// frequency confirm ^^ takes priority in case one sensor reads stray detection
					// AND other sensor reads a good signal. MAY CAUSE AN ISSUE IF READING STRAY AND
					// GOOD SIGNAL DUE TO DELAYS!!
					else if(IR_error_L || IR_error_R)
					   next_state = 0;
					else 
					   begin
						  next_state = state;	// hasn't confirmed frequency
				       end
				end
				
			2:	begin 	// mail delivery state
					state_led = 3'b100;
					next_state = (Go)? 0: state;	// if no Go signal, ?????
					// Go signal = movement
				end
			default: begin
				//next_state = 0;
				state_led = 3'b111;	// ERROR
				end
					// stay still always until inputs next state
			endcase
			if(freq_confirm_L)
				{LED2,LED1} = 2'b01;
			else if(freq_confirm_R)
				{LED2,LED1} = 2'b10;
			else
				{LED2,LED1} = 0;
	end
	
// NOTE: removed all non-blocking assignments

endmodule

// list of current issues:
// rover only staying still while button is pressed continuously
// therefor, need to simulate IR_frequency detect to see how freq_confirm working