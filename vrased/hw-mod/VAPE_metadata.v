
module  VAPE_metadata (

// OUTPUTs
    per_dout,                       // Peripheral data output
    ER_min,                          // VAPE ER_min
    ER_max,                          // VAPE ER_max
    OR_min,                          // VAPE OR_min
    OR_max,                          // VAPE OR_max

// INPUTs
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst,                         // Main system reset
    exec_flag                          // VAPE exec_flag TODO: change to input
);

// OUTPUTs
//=========
output      [15:0] per_dout;        // Peripheral data output
output      [15:0] ER_min;                          // VAPE ER_min
output      [15:0] ER_max;                          // VAPE ER_max
output      [15:0] OR_min;                          // VAPE OR_min
output      [15:0] OR_max;                          // VAPE OR_max

// INPUTs
//=========
input              mclk;            // Main system clock
input       [13:0] per_addr;        // Peripheral address
input       [15:0] per_din;         // Peripheral data input
input              per_en;          // Peripheral enable (high active)
input        [1:0] per_we;          // Peripheral write enable (high active)
input              puc_rst;         // Main system reset
input             exec_flag;                          // VAPE exec_flag


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// VAPE's metadta consists of
//  - 32*8 = 16*16 = 256 bits of challenge
//  - 16 bits of ER_min
//  - 16 bits of ER_max
//  - 16 bits of OR_min
//  - 16 bits of OR_max
//  - 1 bit of exec_flag
parameter              CHAL_SIZE  =  32;            // 32 bytes              
parameter              CHAL_ADDR_MSB   = 3;         // Address stored in 16-bit registers, address 32*8 bits using 16-bit registers, need 4 bits -> 3 MSB (start from 0)    

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0160;
parameter       [13:0] CHAL_PER_ADDR   = 14'h0a0; // Start from h140

                                                         
// Decoder bit width (defines how many bits are considered)
parameter              DEC_WD      =  4;                 // TODO:
                                                         
// Register addresses offset                             
parameter [DEC_WD-1:0] ERMIN      =  'h0,               
                       ERMAX      =  'h1,               
                       ORMIN      =  'h2,               
                       ORMAX      =  'h3,
                       EXECFLAG   =  'h4,
                       CHAL       =  'h5;            
                                                         
                                                         
// Register one-hot decoder utilities                    
parameter              DEC_SZ      =  (1 << DEC_WD);        
parameter [DEC_SZ-1:0] BASE_REG   =  {{DEC_SZ-1{1'b0}}, 1'b1};
                                                         
// Register one-hot decoder                              
parameter [DEC_SZ-1:0] ERMIN_D  = (BASE_REG << ERMIN), 
                       ERMAX_D  = (BASE_REG << ERMAX), 
                       ORMIN_D  = (BASE_REG << ORMIN), 
                       ORMAX_D  = (BASE_REG << ORMAX),
                       EXECFLAG_D  = (BASE_REG << EXECFLAG);
                       
//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel      =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr     =  {1'b0, per_addr[DEC_WD-2:0]};

// Register address decode
wire [DEC_SZ-1:0] reg_dec      = (ERMIN_D  &  {DEC_SZ{(reg_addr==ERMIN)}}) |
                                 (ERMAX_D  &  {DEC_SZ{(reg_addr==ERMAX)}}) |
                                 (ORMIN_D  &  {DEC_SZ{(reg_addr==ORMIN)}}) |
                                 (ORMAX_D  &  {DEC_SZ{(reg_addr==ORMAX)}}) |
                                 (EXECFLAG_D  &  {DEC_SZ{(reg_addr==EXECFLAG)}});
                                 


// Read/Write probes
wire              reg_write =  |per_we & reg_sel;
wire              reg_read  = ~|per_we & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {512{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {512{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// ER_min Register
//-----------------
reg  [15:0] ermin;

wire       ermin_wr  = reg_wr[ERMIN];
wire [15:0] ermin_nxt = per_din;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        ermin <=  16'h0;
  else if (ermin_wr)  ermin <=  ermin_nxt;
  
// ER_max Register
//-----------------
reg  [15:0] ermax;

wire       ermax_wr  = reg_wr[ERMAX];
wire [15:0] ermax_nxt = per_din;

always @ (posedge mclk or posedge puc_rst)
if (puc_rst)        ermax <=  16'h0;
else if (ermax_wr) ermax <=  ermax_nxt;

// OR_min Register
//-----------------
reg  [15:0] ormin;

wire       ormin_wr  = reg_wr[ORMIN];
wire [15:0] ormin_nxt = per_din;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        ormin <=  16'h0;
  else if (ormin_wr) ormin <=  ormin_nxt;
  
// OR_max Register
//-----------------
reg  [15:0] ormax;

wire       ormax_wr  = reg_wr[ORMAX];
wire [15:0] ormax_nxt = per_din;

always @ (posedge mclk or posedge puc_rst)
if (puc_rst)        ormax <=  16'h0;
else if (ormax_wr) ormax <=  ormax_nxt;
  
// exec_flag Register
//-----------------
reg   exec;

//wire       exec_wr  = reg_wr[EXECFLAG];
//wire  exec_nxt = |per_din;

always @ (posedge mclk or posedge puc_rst)
if (puc_rst)        exec <=  16'h0;
else                exec <=  exec_flag;
  
// Challenge Register
//-----------------


wire   [CHAL_ADDR_MSB:0] chal_addr_reg = per_addr-CHAL_PER_ADDR;
wire                     chal_cen      = per_en & per_addr >= CHAL_PER_ADDR & per_addr < CHAL_PER_ADDR+(CHAL_SIZE/4);
wire    [15:0]           chal_dout;
wire    [1:0]            chal_wen      = per_we & {2{per_en}};

chalmem #(CHAL_ADDR_MSB, CHAL_SIZE)
challenges (

    // OUTPUTs
    .ram_dout    (chal_dout),           // Program Memory data output
    // INPUTs
    .ram_addr    (chal_addr_reg),       // Program Memory address
    .ram_cen     (~chal_cen),           // Program Memory chip enable (low active)
    .ram_clk     (mclk),                // Program Memory clock
    .ram_din     (per_din),             // Program Memory data input
    .ram_wen     (~chal_wen)            // Program Memory write enable (low active)
);
wire [15:0]           chal_rd       = chal_dout & {16{chal_cen & ~|per_we}};


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] ermin_rd     = ermin             & {16{reg_rd[ERMIN]}};
wire [15:0] ermax_rd     = ermax             & {16{reg_rd[ERMAX]}};
wire [15:0] ormin_rd     = ormin             & {16{reg_rd[ORMIN]}};
wire [15:0] ormax_rd     = ormax             & {16{reg_rd[ORMAX]}};
wire [15:0] exec_rd      = {15'h000, exec} & {16{reg_rd[EXECFLAG]}};

wire [15:0] per_dout  =  ermin_rd  |
                         ermax_rd  |
                         ormin_rd  |
                         ormax_rd  |
                         exec_rd   |
                         chal_rd;
                         
wire [15:0] ER_min = ermin;
wire [15:0] ER_max = ermax;
wire [15:0] OR_min = ormin;
wire [15:0] OR_max = ormax;

endmodule