
// =====================================================
// Copyright (c) Microsoft Corporation.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =====================================================



module msftDvIp_riscv_memory_v0 #(
    parameter IROM_INIT_FILE  = "",
    parameter IRAM_INIT_FILE  = "",
    parameter DATA_WIDTH=32,
    parameter IROM_DEPTH='h4000,
    parameter IRAM_DEPTH='h1_0000,
    parameter DRAM_DEPTH='h4000
  )  (

  input                     clk_i,
  input                     rstn_i,

  input                     IROM_EN_i,
  input  [31:0]             IROM_ADDR_i,
  output [DATA_WIDTH-1:0]   IROM_RDATA_o,
  output                    IROM_READY_o,
  output                    IROM_ERROR_o,

  input                     IRAM_EN_i,
  input  [31:0]             IRAM_ADDR_i,
  input  [DATA_WIDTH-1:0]   IRAM_WDATA_i,
  input                     IRAM_WE_i,
  input  [3:0]              IRAM_BE_i,
  output [DATA_WIDTH-1:0]   IRAM_RDATA_o,
  output                    IRAM_READY_o,
  output                    IRAM_ERROR_o,

  input                     DRAM_EN_i,
  input  [31:0]             DRAM_ADDR_i,
  input  [DATA_WIDTH-1:0]   DRAM_WDATA_i,
  input                     DRAM_WE_i,
  input  [3:0]              DRAM_BE_i,
  output [DATA_WIDTH-1:0]   DRAM_RDATA_o,
  output                    DRAM_READY_o,
  output                    DRAM_ERROR_o,

  input                     tsmap_cs_i,
  input  [15:0]             tsmap_addr_i,
  output [DATA_WIDTH-1:0]   tsmap_rdata_o
);


//===============================================
// Internal Wires
//===============================================
wire                  clk;
wire                  rstn;

wire                  IROM_EN;
wire [31:0]           IROM_ADDR;
wire [DATA_WIDTH-1:0]   IROM_RDATA;

wire                  IRAM_EN;
wire [31:0]           IRAM_ADDR;
wire [DATA_WIDTH-1:0]   IRAM_WDATA;
wire                  IRAM_WE;
wire [3:0]            IRAM_BE;
wire [DATA_WIDTH-1:0]   IRAM_RDATA;
wire                  IRAM_READY;
wire                  IRAM_ERROR;

wire                  DRAM_EN;
wire [31:0]           DRAM_ADDR;
wire [DATA_WIDTH-1:0]   DRAM_WDATA;
wire                  DRAM_WE;
wire [3:0]            DRAM_BE;
wire [DATA_WIDTH-1:0]   DRAM_RDATA;
wire                  DRAM_READY;
wire                  DRAM_ERROR;

localparam CBIT9 = (DATA_WIDTH == 33) ? 9 : 8;

//===============================================
// IROM
//===============================================
msftDvIp_fpga_block_ram_model #(
    .RAM_WIDTH (DATA_WIDTH),
    .RAM_DEPTH (IROM_DEPTH),
    .INIT_FILE (IROM_INIT_FILE)
  ) irom (
    .clk    (clk),
    .cs     (IROM_EN),
    .dout   (IROM_RDATA),
    .addr   (IROM_ADDR[15:2]),
    .din    ({DATA_WIDTH{1'b0}}),
    .we     (1'b0)
  );
    
//===============================================
// IRAM
//===============================================
msftDvIp_fpga_block_ram_byte_wr_model #(
    .RAM_WIDTH        (DATA_WIDTH),
    .RAM_DEPTH        (IRAM_DEPTH),
    .INIT_FILE        (IRAM_INIT_FILE)
  ) iram (
    .clk    (clk),
    .cs     (IRAM_EN),
    .addr   (IRAM_ADDR[17:2]),
    .dout   (IRAM_RDATA),
    .din    (IRAM_WDATA),
    .we     (IRAM_WE),
    .wstrb({ {CBIT9{IRAM_BE[3]}}, {8{IRAM_BE[2]}}, {8{IRAM_BE[1]}}, {8{IRAM_BE[0]}} }),
    .ready  (IRAM_READY)
  );

//===============================================
// DRAM
//===============================================
msftDvIp_fpga_block_ram_2port_model #(
    .RAM_WIDTH        (DATA_WIDTH),
    .RAM_DEPTH        (DRAM_DEPTH),
    .INIT_FILE        ("")
  ) dram (
    .clk(clk),
    .cs(DRAM_EN),
    .dout(DRAM_RDATA),
    .addr(DRAM_ADDR[15:2]),
    .din(DRAM_WDATA),
    .we(DRAM_WE),
    .wstrb({ {CBIT9{DRAM_BE[3]}}, {8{DRAM_BE[2]}}, {8{DRAM_BE[1]}}, {8{DRAM_BE[0]}} }),
    .ready(dram_rdy),
    .cs2(tsmap_cs_i),
    .addr2(tsmap_addr_i[15:0]),
    .dout2(tsmap_rdata_o)
  );

//===============================================
// Connect ports
//===============================================
assign clk = clk_i;
assign rstn = rstn_i;

assign IROM_EN = IROM_EN_i;
assign IROM_ADDR = IROM_ADDR_i;
assign IROM_RDATA_o = IROM_RDATA;
assign IROM_READY_o = 1'b1;
assign IROM_ERROR_o = 1'b0;

assign IRAM_EN = IRAM_EN_i;
assign IRAM_ADDR = IRAM_ADDR_i;
assign IRAM_WDATA = IRAM_WDATA_i;
assign IRAM_WE = IRAM_WE_i;
assign IRAM_BE = IRAM_BE_i;
assign IRAM_RDATA_o = IRAM_RDATA;
assign IRAM_READY_o = 1'b1;
assign IRAM_ERROR_o = 1'b0;

assign DRAM_EN = DRAM_EN_i;
assign DRAM_ADDR = DRAM_ADDR_i;
assign DRAM_WDATA = DRAM_WDATA_i;
assign DRAM_WE = DRAM_WE_i;
assign DRAM_BE = DRAM_BE_i;
assign DRAM_RDATA_o = DRAM_RDATA;
assign DRAM_READY_o = 1'b1;
assign DRAM_ERROR_o = 1'b0;

endmodule 
