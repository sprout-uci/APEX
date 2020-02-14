
module  VAPE_EXEC_flag (
    clk,
    //
    pc,
    //
    data_addr,
    data_en,
    //
    dma_addr,
    dma_en,
    //
    EXEC_min,
    EXEC_max,
    
    reset
);

input		clk;
input   [15:0]  pc;
input   [15:0]  data_addr;
input           data_en;
input   [15:0]  dma_addr;
input           dma_en;
input   [15:0]  EXEC_min;
input   [15:0]  EXEC_max;
output          reset;

parameter RESET_HANDLER = 16'h0000;
// State codes
parameter EXEC  = 1'b0, ABORT = 1'b1;
//-------------Internal Variables---------------------------
reg             state;
reg             exec_res;
//

initial
    begin
        state = ABORT;
        exec_res = 1'b1;
    end

wire is_write_EXEC = data_en && (data_addr >= EXEC_min && data_addr <= EXEC_max);
wire is_write_DMA_EXEC = dma_en && (dma_addr >= EXEC_min && dma_addr <= EXEC_max);
wire reset_complete = pc == RESET_HANDLER;

wire EXEC_change = is_write_EXEC || is_write_DMA_EXEC;

always @(*)
if( state == EXEC && EXEC_change) 
    state <= ABORT;
else if (state == ABORT && reset_complete)
    state <= EXEC;
else state <= state;

always @(*)
if (state == EXEC && EXEC_change)
    exec_res <= 1'b1;
else if (state == ABORT && reset_complete && !EXEC_change)
    exec_res <= 1'b0;
else if (state == ABORT)
    exec_res <= 1'b1;
else if (state == EXEC)
    exec_res <= 1'b0;
else exec_res <= 1'b0;

assign reset = exec_res;

endmodule
