`timescale 1ns / 1ps


module rover_movement(
input [3:0] signal,
input limit_a, limit_b,	// current protection
input clk,
input [1:0] state,	// if on then does all this

output reg [3:0] pattern,	// enA = 2-bit. enB = 2-bit
output reg enA,	// determined by PWM module
output reg enB,	// determined by PWM module
output reg [1:0] start_stop
    );
 
 initial begin
 start_stop = 0;
 end
 reg [7:0] PWM_a, PWM_b;	// to use in PWM module
 
 // Initialize the parameters for the movement
 localparam left = 4'b1010;	// first 2 bits = left side
 localparam right = 4'b0101;
 localparam straight = 4'b0110; // 3 & 2 = on
 localparam stop = 4'b0000;

 localparam count_max = 255;
 //reg [1:0] start_stop = 0;    // if stop pattern and 0, go, if stop pattern and 1, stop
 reg [3:0] last_sig = 0;
 reg [3:0] next_pattern;
 reg [3:0] last_pattern;
 reg [7:0] count = 0;
 
   always @ (posedge clk) // determining direction
    begin
    	if(state == 0)	// in movement state
    		begin
                last_sig <= (signal == 4'b1111)? last_sig : signal;
                // start_stop flag tells bot when 4'b0000 means begining or end
                // signal == 4'b0000 --> all IPS sensors reading
                // start_stop == 2'b00 --> begining position
                // start_stop == 2'b01 --> Movement
                // start_stop == 2'b10 --> ending position
                start_stop <=  ((signal == 4'b0000) && (start_stop == 2'b00))? 2'b01 : // 0->1 = first time
                               ((signal == 4'b0000) && (start_stop == 2'b01) && (last_sig != 4'b0000))? 2'b10 : start_stop;// 1->2 = stop
                              // ^^^ when idle on the tape, will continuous signal 4'b0000...
                              // NOTE: this bit only sets duty cycle to 0%, not pattern


                last_pattern <= pattern;
                pattern <= next_pattern;
                
                count <= count + 1;
                if(count == count_max)
                    count <= 0;
                else begin
                    enA <= (PWM_a > count)? 1 : 0;
                    enB <= (PWM_b > count)? 1 : 0;
                end
    		end // state conditional
        else begin
            last_pattern <= pattern;
            pattern <= next_pattern;
            enA <= 0;
            enB <= 0;
        end
     end   // always block
     
     always@(*) begin
         if(state == 0) // in movement state
            begin
              //last_sig   = (signal == 4'b1111)? last_sig : signal;
                            
              next_pattern   =  ((signal == 4'b1001) || (signal == 4'b0110))? straight :
                                ((signal == 4'b1101) || (signal == 4'b0001) || (signal == 4'b0111) || (signal == 4'b0101))? left :
                                ((signal == 4'b1011) || (signal == 4'b1000) || (signal == 4'b1110) || (signal == 4'b1010))? right :
                                (signal == 4'b1111)? last_pattern :
                                // ((signal == 4'b1111) && ((last_sig == 4'b1101) || (last_sig == 4'b0001) || (last_sig == 4'b0111) || (last_sig == 4'b0101)))? left :
                                // ((signal == 4'b1111) && ((last_sig == 4'b1011) || (last_sig == 4'b1000) || (last_sig == 4'b1110) || (last_sig == 4'b1010)))? right :
                                // ((signal == 4'b1111) && (last_sig == 4'b0000))? stop :  // if no IPS readings since startup, keep stopped
                                (signal == 4'b0000)? straight : last_pattern;//stop; going to only use PWM for stop
                // start stop = 0 at go, 1 at stop
              if(start_stop == 2'b01) begin // only begins once go signal achieved
                  PWM_a =   (limit_a)? 8'b00000000 :
                            (pattern == straight)? 8'b11100000 :
                            (pattern == left)? 8'hFF ://8'b10111111 :    // 75% power
                            (pattern == right)? 8'b01111111 : PWM_a;  // else it's stopped, disabled
// switched final ': else' to be PWM_x instead of 0!!!
                  PWM_b =   (limit_a)? 8'b00000000 :
                            (pattern == straight)? 8'b11100000 :
                            (pattern == left)? 8'b01111111 :    // 75% power
                            (pattern == right)? 8'hFF : PWM_b;//8'b10111111 : PWM_b;  // else it's stopped, disabled
                  // for some reason, (limit_b) is true with no current
              end
              else  // start_stop flag says stop
                  {PWM_a, PWM_b} = 0;  // stop, no move pls    
            end // state conditional
        else begin // IR detection state, ignore IPS sensor
            {PWM_a, PWM_b} = 0;    // using IR circuit right now...
            next_pattern = stop;
        end
     end
     
 endmodule