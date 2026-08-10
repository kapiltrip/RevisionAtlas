/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 03: AXI-Stream IPs
 * Lecture path: Lessons 43-44 - AXI-Stream FIFO Alternate
 * Downloadable source page: Lesson 044
 * Module: axis_fifo
 * Role: Instructor design RTL
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - The current memory head is presented through the alternate combinational output style.
 * - One clock domain carries TDATA, TKEEP, and TLAST.
 * - The course pointer, count, full, and empty rules are preserved.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - TSTRB, TID, TDEST, TUSER, CDC support, and parameterization are absent.
 * - The course event-priority behavior is retained rather than redesigned.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - The read-memory style assumes a target that can present the addressed entry as written.
 * - A synchronous block RAM may require a different registered architecture, which is intentionally not added here.
 */
module axis_fifo
 (
 // Signal definition - aclk: clock used to sample the course FSM and interface handshakes on rising edges.
 input wire aclk,
 // Signal definition - aresetn: active-LOW reset for the course FSM and handshake outputs.
 input wire aresetn,
 // Signal definition - s_axis_tvalid: AXI-Stream input VALID driven by the upstream Transmitter.
 input wire s_axis_tvalid,
 // Signal definition - s_axis_tdata: AXI-Stream input payload associated with the current offered beat.
 input wire [7:0] s_axis_tdata,
 // Signal definition - s_axis_tkeep: AXI-Stream input byte-lane qualifier stored and forwarded with TDATA.
 input wire s_axis_tkeep,
 // Signal definition - s_axis_tlast: AXI-Stream input packet-end marker associated with the current beat.
 input wire s_axis_tlast,

 // Signal definition - m_axis_tvalid: AXI-Stream output VALID presented to the downstream Receiver.
 output wire m_axis_tvalid, // output to mux
 // Signal definition - m_axis_tdata: AXI-Stream output payload for the currently offered beat.
 output wire [7:0] m_axis_tdata, // output to mux
 // Signal definition - m_axis_tkeep: AXI-Stream output byte-lane qualifier paired with TDATA.
 output wire m_axis_tkeep, // output to mux
 // Signal definition - m_axis_tlast: AXI-Stream output packet-end marker paired with the current beat.
 output wire m_axis_tlast, // output to mux
 // Signal definition - m_axis_tready: AXI-Stream output READY returned by the downstream Receiver.
 input wire m_axis_tready // input from mux
);

// Signal definition - mem_d: FIFO array storing each queued AXI-Stream TDATA byte.
reg [7:0] mem_d [16];
// Signal definition - mem_k: FIFO array storing the TKEEP qualifier paired with each queued data byte.
reg mem_k [16];
// Signal definition - mem_l: FIFO array storing the TLAST marker paired with each queued data byte.
reg mem_l [16];

// Signal definition - wr_ptr: FIFO write pointer selecting the next stored entry.
reg [4:0] wr_ptr;
// Signal definition - rd_ptr: FIFO read pointer selecting the current output entry.
reg [4:0] rd_ptr;

// Signal definition - full: FIFO full indication derived from the retained course occupancy threshold.
wire full;
// Signal definition - empty: FIFO empty indication derived from zero occupancy.
wire empty;
// Signal definition - count: FIFO occupancy; empty is 0 and the retained course full threshold is 15.
reg [4:0] count;

assign full = (count == 5'd15) ? 1 : 0;
assign empty = (count == 5'd0) ? 1 : 0;

always @(posedge aclk) begin
 if(aresetn == 1'b0) begin
 wr_ptr <= 0;
 rd_ptr <= 0;
 count <= 0;

 //initialize memory
 for (int i = 0; i < 16; i++) begin
 mem_d[i] <= 8'h00;
 mem_k[i] <= 1'b0;
 mem_l[i] <= 1'b0;
 end
 end
 //update fifo memory
 else if (s_axis_tvalid == 1'b1 && full == 1'b0) begin
 mem_d[wr_ptr] <= s_axis_tdata;
 mem_k[wr_ptr] <= s_axis_tkeep;
 mem_l[wr_ptr] <= s_axis_tlast;
 wr_ptr <= wr_ptr + 1;
 count <= count + 1;
 end
 // Read data from the FIFO if it's not empty and mux is ready
 else if (m_axis_tready == 1'b1 && empty == 1'b0) begin
 rd_ptr <= rd_ptr + 1;
 count <= count - 1;
 end
end


assign m_axis_tdata = (m_axis_tvalid == 1'b1) ? mem_d[rd_ptr] : 8'h0;
assign m_axis_tkeep = (m_axis_tvalid == 1'b1) ? mem_k[rd_ptr] : 1'b0;
assign m_axis_tlast = (m_axis_tvalid == 1'b1) ? mem_l[rd_ptr] : 1'b0;
assign m_axis_tvalid = (count > 0) ? 1'b1 : 1'b0;

endmodule
