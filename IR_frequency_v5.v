`timescale 1ns / 1ps

// add in the no data display
// Infrared Frequency detection and display

// Version 4: removed HZLED funcionality
//              -changed freq_confirm to 2 bit var (from 1 bit), keeps track of which mailbox as well as confirms
//              -changed else block to conditional upon RM state. Makes sure freq_confirm keeps driving until mail is delivered
//              -ADDED ANOTHER IRsignal input!!
// also, saved over V3... might need to go back to group folder and redownload
// MAJOR CHOICE: keep L and R identification here
//      OR: revert back to only one sided inputs and let state machine decide which side!!!!!!
module IR_frequency(
    input clk, 
    input IRsignal, // MSB = left side, LSB = right side!!!!!!
    input [1:0] state,
    output reg [1:0] freq_confirm, // 0 = off, 1 = 10 Hz, 2 = 100 Hz, 3 = 1Khz
    output reg error_flag   // go back to movement state, stray IR detection confirmation
    );


// Going to confirm the mailbox by polling twice.
// 10-1k Hz going to be chosen from 3 different ranges.


// previous variables: no _L or _R, IRsignal was 1 bit, so was prevIR

reg [26:0] fr_count; // counting up to 100 million
reg [1:0] last;
reg [10:0] data_store;  // register to count data, data/8 = hertz/8
wire [10:0] data_store_net; // -------------------------------------------------------- ?????
reg [7:0] data;   // LSB side of IRsignal input
// changed mailbox/prevmailbox from 3 bit to 2 bit
reg [1:0] mailbox;
reg [1:0] prev_mailbox; // to compare current mailbox with for confirmation
reg IR;
reg prevIR;
reg nextIR;
reg [2:0] stray_detect = 0;
// reg [2:0] freq_flag;

initial 
begin
    {fr_count, last, data_store, data, mailbox, prev_mailbox, IR, prevIR} = 0;
end

always@(posedge clk)
    begin
        if(state == 1)  
            begin
                fr_count <= fr_count + 1;
                prevIR <= IR;
                IR <= nextIR;
                data <= (IR && !prevIR)? data + 1 :
                        (fr_count == 0)? 0 : data;
                data_store <= data*5;
//             end
             
                if(fr_count == 20000000) // 20 million = 1/5th of 100 MHz
                    begin 
                        fr_count <= 0;
                    
                        // NOTE: data_store, mailbox, and prev_mailbox all must have blocking assignments
                        //data_store <= 0;
                        //data <= 0;
                        // mailbox is current selection
                    
                        prev_mailbox <= mailbox;
                    
                        mailbox <=  ((data_store >= 8) && (data_store <= 20)) ? 1 :
                                    ((data_store >= 80) && (data_store <= 200)) ? 2 :
                                    ((data_store >= 800) && (data_store <= 1200)) ? 3 : 0;
                     
                        data <= 0;
                        //data_store <= 0;
                        if(prev_mailbox == mailbox) 
                            begin
                                if(mailbox == 0)
                                    stray_detect = stray_detect + 1;
                                else
                                    stray_detect = 0;
                                freq_confirm <= mailbox;  // frequency has been confirmed
                            end
                        else
                           freq_confirm <= 0;
                        {stray_detect,error_flag} <= (stray_detect == 5)? {3'b000,1'b1} : {stray_detect,1'b0};
                    end
         end // end IR state
       if(state == 0) // different state
        begin 
            freq_confirm <= 0;  // confirm flag needs to be reset for next IR state
        end
        
    end
always@(*) begin
    if(state == 1) begin
        nextIR <= IRsignal;
        // if(IR && !prevIR)
        //     data = data + 1;
        // data_store = data * 5;
    end
end

endmodule
