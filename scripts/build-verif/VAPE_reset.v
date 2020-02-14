
module  VAPE_reset (
    clk,
    //
    pc,
    //
    ER_min,
    ER_max,
    //
    OR_min,
    OR_max,
    //
    reset,

    exec
);

input		clk;
input   [15:0]  pc;
//
input   [15:0]  ER_min;
input   [15:0]  ER_max;
//
input   [15:0]  OR_min;
input   [15:0]  OR_max;
//
input		reset;
//
output          exec;

// State codes
parameter EXEC  = 1'b0, ABORT = 1'b1;
//-------------Internal Variables---------------------------
reg             state;
reg             exec_res;
//

initial
    begin
        state = ABORT;
        exec_res = 1'b0;
    end

wire is_fst_ER = pc == ER_min;

always @(*)
if( state == EXEC && reset) 
    state <= ABORT;
else if (state == ABORT && is_fst_ER && !reset)
    state <= EXEC;
else state <= state;

always @(*)
if (state == EXEC && reset)
    exec_res <= 1'b0;
else if (state == ABORT && is_fst_ER && !reset)
    exec_res <= 1'b1;
else if (state == ABORT)
    exec_res <= 1'b0;
else if (state == EXEC)
    exec_res <= 1'b1;
else exec_res <= 1'b1;

assign exec = exec_res;

endmodule
