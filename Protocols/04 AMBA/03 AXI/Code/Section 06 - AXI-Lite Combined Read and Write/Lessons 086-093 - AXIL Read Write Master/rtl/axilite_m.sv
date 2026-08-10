/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 06: AXI-Lite Combined Read and Write
 * Lecture path: Lessons 86-93 - Combined AXI-Lite Read/Write Master
 * Downloadable source page: Lesson 092
 * Module: axilite_m
 * Role: Instructor design RTL
 *
 * PRESERVATION:
 * - Module/signal names, executable statements, FSM architecture, and stimulus
 *   are retained. Only comments and one-module-per-file organization were added.
 *
 * ASSUMPTIONS:
 * - new_tx starts one operation; wr HIGH selects write and LOW selects read.
 * - Finite counters report missing acknowledgements.
 * - The design is non-pipelined and single-outstanding.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - Bursts and IDs do not exist in AXI-Lite.
 * - AWPROT/ARPROT wires in the TB are unconnected because the DUT has no corresponding ports.
 * - BRESP is declared but ignored; the write FSM completes from BVALID alone.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Timeouts are course FSM policy, not an AXI requirement.
 * - A subordinate write-error response cannot reach a local status output.
 * - Only one selected read or write path progresses at a time.
 */
module axilite_m
(
  // Signal definition - new_tx: local pulse/level that requests one new transaction.
  input wire     new_tx,
  // Signal definition - wr: operation selector; HIGH chooses write and LOW chooses read.
  input wire     wr,
  // Signal definition - waddr: accepted write address retained for GPIO decode or memory access.
  input wire  [31:0] waddr,
  // Signal definition - raddr: accepted read address retained for GPIO decode or memory access.
  input wire  [31:0] raddr,
  // Signal definition - din: local write/payload data supplied to the manager.
  input wire  [31:0] din,
  // Signal definition - dout: local read/receiver data returned by the design.
  output reg [31:0]  dout,
  // Signal definition - resp: local copy of the completed AXI response.
  output reg [1:0]  resp,
  // Signal definition - wr_timeout: course timeout flag asserted when the matching wait counter expires.
  // Signal definition - rd_timeout: course timeout flag asserted when the matching wait counter expires.
  output reg     wr_timeout, rd_timeout,

  // Signal definition - m_axi_aclk: rising-edge clock for the retained FSM and handshakes.
  input wire    m_axi_aclk,
  // Signal definition - m_axi_aresetn: active-LOW reset for the course state/output logic.
  input wire    m_axi_aresetn,
  // Signal definition - m_axi_awvalid: AXI write-address VALID.
  output reg     m_axi_awvalid,
  // Signal definition - m_axi_awready: AXI write-address READY.
  input wire     m_axi_awready,
  // Signal definition - m_axi_awaddr: AXI write address offered with AWVALID.
  output reg [31: 0] m_axi_awaddr,

  // Signal definition - m_axi_wvalid: AXI write-data VALID.
  output reg     m_axi_wvalid,
  // Signal definition - m_axi_wready: AXI write-data READY.
  input wire     m_axi_wready,
  // Signal definition - m_axi_wdata: AXI write payload.
  output reg [31: 0] m_axi_wdata,
  // Signal definition - m_axi_wstrb: AXI write byte-lane strobes.
  output reg [3: 0] m_axi_wstrb,

  // Signal definition - m_axi_bvalid: AXI write-response VALID.
  input wire     m_axi_bvalid,
  // Signal definition - m_axi_bready: AXI write-response READY.
  output reg     m_axi_bready,
  // Signal definition - m_axi_bresp: AXI write-response status input; the course master ignores it and treats BVALID as completion.
  input wire [1: 0] m_axi_bresp,

  // Signal definition - m_axi_arvalid: AXI read-address VALID.
  output reg     m_axi_arvalid,
  // Signal definition - m_axi_arready: AXI read-address READY.
  input wire     m_axi_arready,
  // Signal definition - m_axi_araddr: AXI read address offered with ARVALID.
  output reg [31: 0] m_axi_araddr,

  // Signal definition - m_axi_rvalid: AXI read-data VALID.
  input wire     m_axi_rvalid,
  // Signal definition - m_axi_rready: AXI read-data READY.
  output reg     m_axi_rready,
  // Signal definition - m_axi_rdata: AXI read payload.
  input wire [31: 0] m_axi_rdata,
  // Signal definition - m_axi_rresp: AXI read-response status.
  input wire [1: 0] m_axi_rresp
);


/////////////write FSM

// Signal definition - wr_idle: numeric encoding of the independent write FSM's inactive state.
localparam wr_idle      = 0,
      wait_for_wr_op   = 1,
      waddr_write    = 2,
      wait_for_wdata_ack = 3,
      wait_for_wr_resp  = 4,
      no_ack_wdata    = 5,
      no_ack_waddr    = 6,
      no_slave_wr_resp  = 7,
      comp_wr_tx     = 8;

// Signal definition - wstate: current/next state used by the instructor FSM.
reg [3:0] wstate   = wr_idle;
// Signal definition - wnext_state: current/next state used by the instructor FSM.
reg [3:0] wnext_state = wr_idle;
// Signal definition - wr_count: write-channel no-acknowledgement timer; the course FSM times out at its terminal count.
reg [3:0] wr_count  = 0;

////////////////reset decoding
always @(posedge m_axi_aclk) begin
  if (m_axi_aresetn == 1'b0)
    wstate <= wr_idle;
  else
    wstate <= wnext_state;
end

/////////////////next state decoder
always @(*) begin
  case (wstate)
    wr_idle: begin
      m_axi_awvalid = 0;
      m_axi_awaddr = 0;
      m_axi_wvalid = 0;
      m_axi_wdata  = 0;
      m_axi_wstrb  = 0;
      m_axi_bready = 0;
      wr_timeout  = 1'b0;
      if(new_tx == 1'b1)
      wnext_state  = wait_for_wr_op;
      else
      wnext_state  = wr_idle;
    end

    wait_for_wr_op: begin
      if (wr == 1)
        wnext_state = waddr_write;
      else
        wnext_state = wr_idle;
    end

    waddr_write: begin
      m_axi_wstrb  = 4'b1111;
      m_axi_awvalid = 1;
      m_axi_wvalid = 1;
      m_axi_awaddr = waddr;
      m_axi_wdata  = din;
      m_axi_bready = 1;

      if (m_axi_awready == 1 && m_axi_wready == 1)
        wnext_state = wait_for_wr_resp;
      else if (m_axi_awready == 1)
        wnext_state = wait_for_wdata_ack;
      else if (wr_count == 15)
        wnext_state = no_ack_waddr;
      else
        wnext_state = waddr_write;
    end

    wait_for_wdata_ack: begin
      m_axi_awvalid = 0;
      m_axi_awaddr = 0;
      if (m_axi_wready == 1)
        wnext_state = wait_for_wr_resp;
      else if (wr_count == 14)
        wnext_state = no_ack_wdata;
      else
        wnext_state = wait_for_wdata_ack;
    end

    wait_for_wr_resp: begin
      m_axi_awvalid = 0;
      m_axi_wvalid = 0;
      m_axi_wdata  = 0;
      m_axi_awaddr = 0;
      if (m_axi_bvalid == 1)
        wnext_state = comp_wr_tx;
      else if (wr_count == 14)
        wnext_state = no_slave_wr_resp;
    end

    no_ack_wdata, no_ack_waddr: begin
        wr_timeout = 1'b1;
      if (m_axi_bvalid == 1)
        wnext_state = comp_wr_tx;
      else if (wr_count == 14)
        wnext_state = no_slave_wr_resp;
    end

    no_slave_wr_resp: begin
      wr_timeout = 1'b1;
      wnext_state = wr_idle;
    end

    comp_wr_tx: begin
      m_axi_bready = 0;
      wnext_state = wr_idle;
    end

    default: wnext_state = wr_idle;
  endcase
end

// Signal definition - first: combinational pulse asserted when the write FSM's current and next states differ.
wire first;
// Signal definition - first_d: one-cycle delayed write-state transition pulse used to restart the write timeout counter.
reg first_d;
assign first = (wstate != wnext_state) ? 1'b1 : 0;

always@(posedge m_axi_aclk)
begin
first_d <= first;
end


///////write counter
always @(posedge m_axi_aclk) begin
  case (wstate)
    wr_idle:          wr_count <= 0;

    wait_for_wr_op:       wr_count <= 0;

    waddr_write  :       wr_count <= wr_count + 1;

    wait_for_wdata_ack:
    begin
    if(first_d)
    wr_count <= 0;
    else
    wr_count <= wr_count + 1;
    end

    wait_for_wr_resp:
    begin
    if(first_d)
    wr_count <= 0;
    else
    wr_count <= wr_count + 1;
    end

    no_ack_wdata:
    begin
    if(first_d)
    wr_count <= 0;
    else
    wr_count <= wr_count + 1;
    end

    no_ack_waddr:
    begin
    if(first_d)
    wr_count <= 0;
    else
    wr_count <= wr_count + 1;
    end

    no_slave_wr_resp:      wr_count <= 0;

    comp_wr_tx:         wr_count <= 0;

    default:          wr_count <= 0;
  endcase
end



/////////////////read FSM

// Signal definition - rd_idle: numeric encoding of the independent read FSM's inactive state.
localparam rd_idle     = 0,
      wait_for_rd_op = 1,
      raddr_write   = 2,
      wait_for_rdata = 3,
      no_resp_raddr  = 4,
      no_resp_rdata  = 5,
      comp_rd_tx   = 6;

// Signal definition - rstate: current/next state used by the instructor FSM.
// Signal definition - rnext_state: current/next state used by the instructor FSM.
reg [2:0] rstate   = rd_idle, rnext_state = rd_idle;
// Signal definition - rd_count: read-channel no-acknowledgement timer; the course FSM times out at its terminal count.
reg [3:0] rd_count  = 0;

always @(posedge m_axi_aclk) begin
  if (m_axi_aresetn == 1'b0)
    rstate <= rd_idle;
  else
    rstate <= rnext_state;
end

//////////
always @(*) begin
  case (rstate)
    rd_idle: begin
      m_axi_arvalid = 0;
      m_axi_araddr = 0;
      m_axi_rready = 0;
      dout     = 0;
      resp     = 0;
      rd_timeout  = 1'b0;

      if(new_tx == 1'b1)
      rnext_state  = wait_for_rd_op;
      else
      rnext_state  = rd_idle;

    end

    wait_for_rd_op: begin
      if (wr == 0)
        rnext_state = raddr_write;
      else
        rnext_state = rd_idle;
    end

    raddr_write: begin
      m_axi_arvalid = 1;
      m_axi_araddr = raddr;
      m_axi_rready = 1'b1;

      if(m_axi_arready == 1 && m_axi_rvalid == 1)
        rnext_state = comp_rd_tx;
      else if (m_axi_arready == 1)
        rnext_state = wait_for_rdata;
      else if (rd_count == 15)
        rnext_state = no_resp_raddr;
      else
        rnext_state = raddr_write;
    end

    wait_for_rdata: begin
      m_axi_arvalid = 0;
      m_axi_araddr = 0;
      if (m_axi_rvalid == 1)
        rnext_state = comp_rd_tx;
      else if (rd_count == 14)
        rnext_state = no_resp_rdata;
    end

    no_resp_raddr, no_resp_rdata: begin
      rd_timeout = 1'b1;
      rnext_state = rd_idle;
    end

    comp_rd_tx: begin
      m_axi_rready = 1'b0;
      m_axi_arvalid = 1'b0;
      dout     = m_axi_rdata;
      resp     = m_axi_rresp;
      rnext_state  = rd_idle;
    end

    default: rnext_state = rd_idle;
  endcase
end


// Signal definition - first_r: combinational pulse asserted when the read FSM's current and next states differ.
wire first_r;
// Signal definition - first_d_r: one-cycle delayed read-state transition pulse used to restart the read timeout counter.
reg first_d_r;
assign first_r = (rstate != rnext_state) ? 1'b1 : 0;

always@(posedge m_axi_aclk)
begin
first_d_r <= first_r;
end



//////////////read counter
always @(posedge m_axi_aclk) begin
  case (rstate)
    rd_idle,
    wait_for_rd_op,
    no_resp_raddr,
    no_resp_rdata,
    comp_rd_tx: rd_count <= 0;

    raddr_write : rd_count <= rd_count + 1;
    wait_for_rdata:
    begin
    if(first_d_r)
    rd_count <= 0;
    else
    rd_count <= rd_count + 1;
    end

    default: rd_count <= 0;
  endcase
end




endmodule
