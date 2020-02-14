
module  irq_dma (
    clk,
    //
    pc,
    irq,
    dma_en,
    //
    ER_min,
    ER_max,
    
    exec
);

input		clk;
input   [15:0]  pc;
input           irq;
input           dma_en;
input   [15:0]  ER_min;
input   [15:0]  ER_max;
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

wire irq_or_dma_in_ER = (dma_en || irq) && (pc >= ER_min && pc <= ER_max);
wire is_fst_ER = pc == ER_min;

always @(*)
if( state == EXEC && irq_or_dma_in_ER) 
    state <= ABORT;
else if (state == ABORT && is_fst_ER && !irq_or_dma_in_ER)
    state <= EXEC;
else state <= state;

always @(*)
if (state == EXEC && irq_or_dma_in_ER)
    exec_res <= 1'b0;
else if (state == ABORT && is_fst_ER && !irq_or_dma_in_ER)
    exec_res <= 1'b1;
else if (state == ABORT)
    exec_res <= 1'b0;
else if (state == EXEC)
    exec_res <= 1'b1;
else exec_res <= 1'b1;

assign exec = exec_res;

endmodule
