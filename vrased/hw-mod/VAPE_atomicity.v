
module  VAPE_atomicity (
    clk,    
    pc,     
    ER_min,
    ER_max,
    irq,

    exec   //OUTPUT
);

input		    clk;
input   [15:0]  pc;
input   [15:0]  ER_min;
input   [15:0]  ER_max;
input		irq;
output          exec;

// FSM States //////////////////////////////////////////////////////////
parameter notRC  = 3'b000;
parameter fstRC = 3'b001;
parameter lastRC = 3'b010;
parameter midRC = 3'b011;
parameter kill = 3'b100;
//
parameter SMEM_BASE = 16'hA000;
parameter SMEM_SIZE = 16'h4000;
///////////////////////////////////////////////////////////////////////

wire [15:0] ER_BASE = ER_min;
wire [15:0] LAST_ER_ADDR = ER_max;
/////////////////////////////////////////////////////




reg     [2:0]   pc_state; // 3 bits for 5 states
reg             atomicity_exec;

initial
begin
        pc_state = kill;
        atomicity_exec = 1'b0;
end
	
	
wire not_valid_ER = !(ER_min < ER_max && (ER_max < SMEM_BASE || SMEM_BASE+SMEM_SIZE < ER_min));

wire is_mid_rom = pc > ER_BASE && pc < LAST_ER_ADDR;
wire is_first_rom = pc == ER_BASE;
wire is_last_rom = pc == LAST_ER_ADDR;
wire is_in_rom = is_mid_rom | is_first_rom | is_last_rom;
wire is_outside_rom = pc < ER_BASE | pc > LAST_ER_ADDR;
always @(posedge clk)
begin
    if(not_valid_ER)
        pc_state <= kill;
    else
        begin
        case (pc_state)
            notRC:
                if (is_outside_rom)
                    pc_state <= notRC;
                else if (is_first_rom)
                    pc_state <= fstRC;
                else if (is_mid_rom || is_last_rom)
                    pc_state <= kill;
                else 
                    pc_state <= pc_state;
            
            midRC:
                if (is_mid_rom)
                    pc_state <= midRC;
                else if (is_last_rom)
                    pc_state <= lastRC;
                else if (is_outside_rom || is_first_rom)
                    pc_state <= kill; 
                else
                    pc_state <= pc_state;
                    
            fstRC:
                if (is_mid_rom) 
                    pc_state <= midRC;
                else if (is_first_rom) 
                    pc_state = fstRC;
                else if (is_outside_rom  || is_last_rom) 
                    pc_state <= kill;
                else 
                    pc_state <= pc_state;
                
            lastRC:
                if (is_outside_rom)
                    pc_state <= notRC;
                else if (is_last_rom) 
                    pc_state = lastRC;
                else if (is_first_rom || is_last_rom || is_mid_rom)
                  pc_state <= kill;
                else pc_state <= pc_state;
                    
            kill:
                if (is_first_rom)
                    pc_state <= fstRC;
                else
                    pc_state <= pc_state;
                    
        endcase
        end
end

////////////// OUTPUT LOGIC //////////////////////////////////////
always @(posedge clk)
begin
    if (not_valid_ER)
        atomicity_exec <= 1'b0;
    else if (
	    (pc_state == kill && !is_first_rom) ||
        (pc_state == fstRC && !is_mid_rom && !is_first_rom) ||
        (pc_state == lastRC && is_mid_rom) ||
        (pc_state == midRC && is_outside_rom) ||
        (pc_state == notRC && (is_mid_rom || is_last_rom))
    )begin
            atomicity_exec <= 1'b0;
    end
    else begin
            atomicity_exec <= 1'b1;
    end

end


assign exec = atomicity_exec;

endmodule
