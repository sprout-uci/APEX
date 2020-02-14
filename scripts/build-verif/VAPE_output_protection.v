
module  VAPE_output_protection (
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
    ER_min,
    ER_max,
    //
    OR_min,
    OR_max,
    
    exec
);

input		clk;
input   [15:0]  pc;
input   [15:0]  data_addr;
input           data_en;
input   [15:0]  dma_addr;
input           dma_en;
input   [15:0]  ER_min;
input   [15:0]  ER_max;
input   [15:0]  OR_min;
input   [15:0]  OR_max;
output          exec;

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
        exec_res = 1'b0;
    end

wire is_write_OR = data_en && (data_addr >= OR_min && data_addr <= OR_max);
wire is_write_DMA_OR = dma_en && (dma_addr >= OR_min && dma_addr <= OR_max);
wire is_fst_ER = pc == ER_min;
wire pc_in_ER = (pc >= ER_min && pc <= ER_max);
wire is_reset = (pc == RESET_HANDLER);

wire not_valid_OR = !(OR_min < OR_max);

wire OR_change = (is_write_OR || is_write_DMA_OR);

always @(*)
if( is_reset || not_valid_OR ) 
    state <= ABORT;
else if( state == EXEC && OR_change && !pc_in_ER) 
    state <= ABORT;
else if (state == ABORT && is_fst_ER)
    state <= EXEC;
else state <= state;

always @(*)
if ( is_reset || not_valid_OR )
    exec_res <= 1'b0;    
else if (state == EXEC && OR_change && !pc_in_ER)
    exec_res <= 1'b0;
else if (state == ABORT && is_fst_ER)
    exec_res <= 1'b1;
else if (state == ABORT)
    exec_res <= 1'b0;
else if (state == EXEC)
    exec_res <= 1'b1;
else exec_res <= 1'b1;

assign exec = exec_res;

endmodule
