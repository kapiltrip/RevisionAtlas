/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 09: AXI4 Burst Modes
 * Lecture path: Lessons 115-128 - AXI4 FIXED, INCR, and WRAP Bursts
 * Downloadable source page: Lesson 125
 * Module: axi4_slave
 * Role: Instructor design RTL
 *
 * PRESERVATION:
 * - Module/signal names, executable statements, FSM architecture, and stimulus
 *   are retained. Only comments and one-module-per-file organization were added.
 *
 * ASSUMPTIONS:
 * - The course FSMs implement the demonstrated FIXED, INCR, and WRAP modes.
 * - Length, size, and alignment follow the course stimulus.
 * - One manager/subordinate pair shares one clock and active-LOW reset.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - No alternate burst engine, CDC, multi-outstanding scheduler, or absent LOCK/CACHE/PROT/QOS/REGION/USER fields are added.
 * - AWID, WID, ARID, LOCK, CACHE, PROT, QOS, USER, and WLAST inputs are
 *   declared but ignored; BID and RID are always returned as zero.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - WRAP behavior is limited to the supported aligned cases exercised in the course.
 * - Write completion follows the captured AWLEN/count rather than WLAST, and
 *   response IDs cannot identify independent transactions.
 * - System legality depends on the surrounding AXI configuration.
 */
`timescale 1ns / 1ps
module axi4_slave
(
    // Signal definition - s_axi_aclk: rising-edge clock for the retained FSM and handshakes.
    input  wire        s_axi_aclk,
    // Signal definition - s_axi_aresetn: active-LOW reset for the course state/output logic.
    input  wire        s_axi_aresetn,

    // Signal definition - s_axi_awid: AXI write-address ID input; the course slave ignores it and returns a fixed response ID.
    input  wire [2:0]  s_axi_awid,
    // Signal definition - s_axi_awvalid: AXI write-address VALID.
    input  wire        s_axi_awvalid,
    // Signal definition - s_axi_awready: AXI write-address READY.
    output reg         s_axi_awready,
    // Signal definition - s_axi_awaddr: AXI write address offered with AWVALID.
    input  wire [31:0] s_axi_awaddr,
    // Signal definition - s_axi_awlen: AXI write burst length encoded as beats minus one.
    input  wire [7:0]  s_axi_awlen,
    // Signal definition - s_axi_awsize: AXI write beat-size encoding.
    input  wire [2:0]  s_axi_awsize,
    // Signal definition - s_axi_awburst: AXI write burst type encoding.
    input  wire [1:0]  s_axi_awburst,
    // Signal definition - s_axi_awlock: AXI write lock/exclusive attribute input; it is connected but ignored by the course slave.
    input  wire [1:0]  s_axi_awlock,
    // Signal definition - s_axi_awcache: AXI write cache/buffer attribute input; it is connected but ignored by the course slave.
    input  wire [3:0]  s_axi_awcache,
    // Signal definition - s_axi_awprot: write protection attributes are connected but ignored by the course subordinate.
    input  wire [2:0]  s_axi_awprot,
    // Signal definition - s_axi_awqos: AXI write quality-of-service input; it is connected but ignored by the course slave.
    input  wire [3:0]  s_axi_awqos,
    // Signal definition - s_axi_awuser: AXI write-address user sideband input; it is connected but ignored by the course slave.
    input  wire [4:0]  s_axi_awuser,

    // Signal definition - s_axi_wid: write-data transaction ID input; the course slave ignores it.
    input  wire [2:0]  s_axi_wid,
    // Signal definition - s_axi_wvalid: AXI write-data VALID.
    input  wire        s_axi_wvalid,
    // Signal definition - s_axi_wready: AXI write-data READY.
    output reg         s_axi_wready,
    // Signal definition - s_axi_wdata: AXI write payload.
    input  wire [31:0] s_axi_wdata,
    // Signal definition - s_axi_wstrb: AXI write byte-lane strobes.
    input  wire [3:0]  s_axi_wstrb,
    // Signal definition - s_axi_wlast: final write-beat marker input; the course slave ignores it and instead follows its captured length/count.
    input  wire        s_axi_wlast,

    // Signal definition - s_axi_bid: write-response ID forced to zero rather than copied from AWID.
    output reg  [2:0]  s_axi_bid,
    // Signal definition - s_axi_bvalid: AXI write-response VALID.
    output reg         s_axi_bvalid,
    // Signal definition - s_axi_bready: AXI write-response READY.
    input  wire        s_axi_bready,
    // Signal definition - s_axi_bresp: AXI write-response status.
    output reg  [1:0]  s_axi_bresp,

    // Signal definition - s_axi_arid: AXI read-address ID input; the course slave ignores it and returns a fixed response ID.
    input  wire [2:0]  s_axi_arid,
    // Signal definition - s_axi_arvalid: AXI read-address VALID.
    input  wire        s_axi_arvalid,
    // Signal definition - s_axi_arready: AXI read-address READY.
    output reg         s_axi_arready,
    // Signal definition - s_axi_araddr: AXI read address offered with ARVALID.
    input  wire [31:0] s_axi_araddr,
    // Signal definition - s_axi_arlen: AXI read burst length encoded as beats minus one.
    input  wire [7:0]  s_axi_arlen,
    // Signal definition - s_axi_arsize: AXI read beat-size encoding.
    input  wire [2:0]  s_axi_arsize,
    // Signal definition - s_axi_arburst: AXI read burst type encoding.
    input  wire [1:0]  s_axi_arburst,
    // Signal definition - s_axi_arlock: AXI read lock/exclusive attribute input; it is connected but ignored by the course slave.
    input  wire [1:0]  s_axi_arlock,
    // Signal definition - s_axi_arcache: AXI read cache/buffer attribute input; it is connected but ignored by the course slave.
    input  wire [3:0]  s_axi_arcache,
    // Signal definition - s_axi_arprot: read protection attributes are connected but ignored by the course subordinate.
    input  wire [2:0]  s_axi_arprot,
    // Signal definition - s_axi_arqos: AXI read quality-of-service input; it is connected but ignored by the course slave.
    input  wire [3:0]  s_axi_arqos,
    // Signal definition - s_axi_aruser: AXI read-address user sideband input; it is connected but ignored by the course slave.
    input  wire [4:0]  s_axi_aruser,

    // Signal definition - s_axi_rid: read-data ID forced to zero rather than copied from ARID.
    output reg  [2:0]  s_axi_rid,
    // Signal definition - s_axi_rvalid: AXI read-data VALID.
    output reg         s_axi_rvalid,
    // Signal definition - s_axi_rready: AXI read-data READY.
    input  wire        s_axi_rready,
    // Signal definition - s_axi_rdata: AXI read payload.
    output reg  [31:0] s_axi_rdata,
    // Signal definition - s_axi_rlast: AXI final read-beat marker.
    output reg         s_axi_rlast,
    // Signal definition - s_axi_rresp: AXI read-response status.
    output reg  [1:0]  s_axi_rresp
	);

// Signal definition - idle: numeric encoding of the FSM's inactive state, where no new AXI transfer is being advanced.
localparam  idle = 0,
            predict_op = 1,
            accept_wr = 2,
            wait_wdata = 3,
            accept_wdata = 4,
            gen_data = 5,
            update_mem = 6,
            check_br_len = 7,
            send_ack = 8,
            accept_rd = 9,
            fetch_rdata = 10,
            send_rdata =11,
            rcheck_br_len = 12,
            fetch_ldata = 13,
            send_rlast = 14,
            write_err = 15,
            comp_rd_tx = 16;




   initial begin
   s_axi_awready = 0;
   s_axi_wready = 0;
   s_axi_bid    =0;
   s_axi_bvalid = 0;
   s_axi_bresp  = 0;
   s_axi_arready = 0;
   s_axi_rid   = 0;
   s_axi_rvalid = 0;
   s_axi_rdata = 0;
   s_axi_rlast = 0;
   s_axi_rresp = 0;
   end


// Signal definition - mem: sixteen-entry, 32-bit teaching memory updated by accepted AXI-Lite writes.
reg [7:0] mem [127:0];

// Signal definition - state: current/next state used by the instructor FSM.
reg [4:0] state = 0;
// Signal definition - i: loop index used by initialization or TB stimulus.
integer i = 0;
// Signal definition - burst_len: latched AWLEN value used by the slave's write-burst control.
// Signal definition - rburst_len: latched ARLEN value used by the slave's read-burst control.
reg [7:0] burst_len = 0,rburst_len = 0;
// Signal definition - waddr: accepted write address retained for GPIO decode or memory access.
// Signal definition - wdata: accepted AXI write payload retained until the course FSM applies it.
// Signal definition - raddr: accepted read address retained for GPIO decode or memory access.
// Signal definition - rdata: AXI read payload.
reg [31:0] waddr = 0, wdata = 0,raddr = 0, rdata = 0;
// Signal definition - wstrb: accepted AXI byte-lane strobes retained with WDATA.
reg [3:0] wstrb = 0;
// Signal definition - timer: handshake timeout counter; reaching 15 sends the retained course FSM to its no-acknowledgement path.
integer timer = 0;
// Signal definition - data_write: WSTRB-masked write payload produced before the GPIO or memory update.
reg [31:0] data_write = 0;
// Signal definition - count: two-cycle lesson-FSM pacing counter used before memory-update/read-response states.
reg [1:0] count = 0;




function [31:0] data_wr_fixed (input [3:0] wstrb, input [31:0] awaddrt);
  begin
     case (wstrb)
      4'b0001: begin
        mem[awaddrt] = wdata[7:0];
      end

      4'b0010: begin
        mem[awaddrt] = wdata[15:8];
      end

      4'b0011: begin
        mem[awaddrt] = wdata[7:0];
        mem[awaddrt + 1] = wdata[15:8];
      end

       4'b0100: begin
         mem[awaddrt] = wdata[23:16];
      end

       4'b0101: begin
        mem[awaddrt] = wdata[7:0];
        mem[awaddrt + 1] = wdata[23:16];
      end


       4'b0110: begin
        mem[awaddrt] = wdata[15:8];
         mem[awaddrt + 1] = wdata[23:16];
      end

       4'b0111: begin
         mem[awaddrt] = wdata[7:0];
         mem[awaddrt + 1] = wdata[15:8];
         mem[awaddrt + 2] = wdata[23:16];
      end

       4'b1000: begin
         mem[awaddrt] = wdata[31:24];
      end

       4'b1001: begin
         mem[awaddrt] = wdata[7:0];
         mem[awaddrt + 1] = wdata[31:24];
      end


       4'b1010: begin
         mem[awaddrt] = wdata[15:8];
         mem[awaddrt + 1] = wdata[31:24];
      end


       4'b1011: begin
         mem[awaddrt] = wdata[7:0];
         mem[awaddrt + 1] = wdata[15:8];
         mem[awaddrt + 2] = wdata[31:24];
      end

      4'b1100: begin
         mem[awaddrt] = wdata[23:16];
         mem[awaddrt + 1] = wdata[31:24];
      end

      4'b1101: begin
        mem[awaddrt] = wdata[7:0];
        mem[awaddrt + 1] = wdata[23:16];
        mem[awaddrt + 2] = wdata[31:24];
      end

      4'b1110: begin
        mem[awaddrt] = wdata[15:8];
        mem[awaddrt + 1] = wdata[23:16];
        mem[awaddrt + 2] = wdata[31:24];
      end

      4'b1111: begin
        mem[awaddrt] = wdata[7:0];
        mem[awaddrt + 1] = wdata[15:8];
        mem[awaddrt + 2] = wdata[23:16];
        mem[awaddrt + 3] = wdata[31:24];
      end
     endcase
    data_wr_fixed =  awaddrt;
end
endfunction


//////////////incr mode
// Signal definition - addr: current byte address passed through the course read-address helper.
reg [31:0] addr = 0;
function [31:0] data_wr_incr (input [3:0] wstrb, input [31:0] awaddrt);
 begin
    case (wstrb)
      4'b0001: begin
        mem[awaddrt] = wdata[7:0];
        addr = awaddrt + 1;
      end

      4'b0010: begin
        mem[awaddrt] = wdata[15:8];
        addr = awaddrt + 1;
      end

      4'b0011: begin
        mem[awaddrt] = wdata[7:0];
        mem[awaddrt + 1] = wdata[15:8];
        addr = awaddrt + 2;
      end

       4'b0100: begin
         mem[awaddrt] = wdata[23:16];
         addr = awaddrt + 1;
      end

       4'b0101: begin
        mem[awaddrt] = wdata[7:0];
         mem[awaddrt + 1] = wdata[23:16];
         addr = awaddrt + 2;
      end


       4'b0110: begin
         mem[awaddrt] = wdata[15:8];
         mem[awaddrt + 1] = wdata[23:16];
         addr = awaddrt + 2;
      end

       4'b0111: begin
         mem[awaddrt] = wdata[7:0];
         mem[awaddrt + 1] = wdata[15:8];
         mem[awaddrt + 2] = wdata[23:16];
         addr = awaddrt + 3;
      end

       4'b1000: begin
         mem[awaddrt] = wdata[31:24];
         addr = awaddrt + 1;
      end

       4'b1001: begin
         mem[awaddrt] = wdata[7:0];
         mem[awaddrt + 1] = wdata[31:24];
         addr = awaddrt + 2;
      end


       4'b1010: begin
         mem[awaddrt] = wdata[15:8];
         mem[awaddrt + 1] = wdata[31:24];
         addr = awaddrt + 2;
      end


       4'b1011: begin
         mem[awaddrt] = wdata[7:0];
         mem[awaddrt + 1] = wdata[15:8];
         mem[awaddrt + 2] = wdata[31:24];
         addr = awaddrt + 3;
      end

      4'b1100: begin
         mem[awaddrt] = wdata[23:16];
         mem[awaddrt + 1] = wdata[31:24];
         addr = awaddrt + 2;
      end

      4'b1101: begin
        mem[awaddrt] = wdata[7:0];
        mem[awaddrt + 1] = wdata[23:16];
        mem[awaddrt + 2] = wdata[31:24];
        addr = awaddrt + 3;
      end

      4'b1110: begin
        mem[awaddrt] = wdata[15:8];
        mem[awaddrt + 1] = wdata[23:16];
        mem[awaddrt + 2] = wdata[31:24];
        addr = awaddrt + 3;
      end

      4'b1111: begin
        mem[awaddrt]     = wdata[7:0];
        mem[awaddrt + 1] = wdata[15:8];
        mem[awaddrt + 2] = wdata[23:16];
        mem[awaddrt + 3] = wdata[31:24];
        addr = awaddrt + 4;
      end
     endcase
    data_wr_incr =  addr;
end
endfunction

/////////////////wrap mode
// Signal definition - boundary_wr: temporary WRAP span calculated from burst length and transfer size.
reg [7:0] boundary_wr;
function  [7:0] wrap_boundary (input [3:0] awlen,input [2:0] awsize);
   begin
      case(awlen)
       4'b0001:
       begin
                case(awsize)
                       3'b000: begin
                       boundary_wr = 2 * 1;
                      end
                       3'b001: begin
                       boundary_wr = 2 * 2;
                       end
                       3'b010: begin
                       boundary_wr = 2 * 4;
                       end
                endcase
          end
       4'b0011:
       begin
                case(awsize)
                       3'b000: begin
                       boundary_wr = 4 * 1;
                      end
                       3'b001: begin
                       boundary_wr = 4 * 2;
                       end
                       3'b010: begin
                       boundary_wr = 4 * 4;
                       end
                endcase
          end

    4'b0111:
       begin
                case(awsize)
                       3'b000: begin
                       boundary_wr = 8 * 1;
                      end
                       3'b001: begin
                       boundary_wr = 8 * 2;
                       end
                       3'b010: begin
                       boundary_wr = 8 * 4;
                       end
                endcase
          end


         4'b1111:
       begin
                case(awsize)
                       3'b000: begin
                       boundary_wr = 16 * 1;
                      end
                       3'b001: begin
                       boundary_wr = 16 * 2;
                       end
                       3'b010: begin
                       boundary_wr = 16 * 4;
                       end
                endcase
          end

     endcase


     wrap_boundary =  boundary_wr;
end
  endfunction
  //////////////////////////////////////////////////////////////

// Signal definition - addr1: first scratch byte address calculated by the WRAP write helper.
// Signal definition - addr2: second scratch byte address calculated by the WRAP write helper.
// Signal definition - addr3: third scratch byte address calculated by the WRAP write helper.
// Signal definition - addr4: fourth scratch byte address calculated by the WRAP write helper.
reg [31:0] addr1, addr2, addr3, addr4;
// Signal definition - nextaddr: declared WRAP-helper scratch register that the supplied lesson never reads or writes; it has no behavioral effect.
// Signal definition - nextaddr2: second declared WRAP-helper scratch register that the supplied lesson never reads or writes; it has no behavioral effect.
reg [31:0] nextaddr, nextaddr2;
function [31:0] data_wr_wrap (input [3:0] wstrb, input [31:0] awaddrt, input [7:0] wboundary);
begin
  case (wstrb)
    /////////////////////////////////////////////////
      4'b0001: begin
        mem[awaddrt] = wdata[7:0];

        if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
        else
           addr1 = awaddrt + 1;

        data_wr_wrap = addr1;
      end

      /////////////////////////////////////////////////

      4'b0010: begin
        mem[awaddrt] = wdata[15:8];

       if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
        else
           addr1 = awaddrt + 1;

      data_wr_wrap = addr1;
      end

      ///////////////////////////////////////////////////

      4'b0011: begin
        mem[awaddrt] = wdata[7:0];

       if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
        else
           addr1 = awaddrt + 1;

       mem[addr1] = wdata[15:8];

       if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

        data_wr_wrap = addr2;

       end

      ///////////////////////////////////////////////

       4'b0100: begin
         mem[awaddrt] = wdata[23:16];

        if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
        else
           addr1 = awaddrt + 1;

       data_wr_wrap = addr1;
      end

      //////////////////////////////////////////////

       4'b0101: begin
        mem[awaddrt] = wdata[7:0];

          if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;


        mem[addr1] = wdata[23:16];


          if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

        data_wr_wrap = addr2;

      end

      ///////////////////////////////////////////////////

       4'b0110: begin
        mem[awaddrt] = wdata[15:8];

          if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;

         mem[addr1] = wdata[23:16];

         if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

        data_wr_wrap = addr2;

      end
    //////////////////////////////////////////////////////////////

       4'b0111: begin
         mem[awaddrt] = wdata[7:0];
          if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;

         mem[addr1] = wdata[15:8];

        if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

         mem[addr2] = wdata[23:16];

        if((addr2 + 1) % wboundary == 0)
           addr3 = (addr2 + 1) - wboundary;
        else
           addr3 = addr2 + 1;

          data_wr_wrap = addr3;
     end

       4'b1000: begin
         mem[awaddrt] = wdata[31:24];

         if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;

           data_wr_wrap = addr1;
      end

       4'b1001: begin
         mem[awaddrt] = wdata[7:0];

         if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;


         mem[addr1] = wdata[31:24];

         if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

        data_wr_wrap = addr2;
      end


       4'b1010: begin
         mem[awaddrt] = wdata[15:8];

         if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;

         mem[addr1] = wdata[31:24];

        if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

        data_wr_wrap = addr2;
      end


       4'b1011: begin
         mem[awaddrt] = wdata[7:0];

          if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;


         mem[addr1] = wdata[15:8];

         if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

         mem[addr2] = wdata[31:24];

        if((addr2 + 1) % wboundary == 0)
           addr3 = (addr2 + 1) - wboundary;
        else
           addr3 = addr2 + 1;

       data_wr_wrap = addr3;

      end

      4'b1100: begin
         mem[awaddrt] = wdata[23:16];

           if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;

         mem[addr1] = wdata[31:24];

         if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

           data_wr_wrap = addr2;
      end

      4'b1101: begin
        mem[awaddrt] = wdata[7:0];

           if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;

        mem[addr1] = wdata[23:16];

         if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

        mem[addr2] = wdata[31:24];

         if((addr2 + 1) % wboundary == 0)
           addr3 = (addr2 + 1) - wboundary;
        else
           addr3 = addr2 + 1;

       data_wr_wrap = addr3;

      end

      4'b1110: begin
        mem[awaddrt] = wdata[15:8];

         if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;

        mem[addr1] = wdata[23:16];

         if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

        mem[addr2] = wdata[31:24];

        if((addr2 + 1) % wboundary == 0)
           addr3 = (addr2 + 1) - wboundary;
        else
           addr3 = addr2 + 1;

           data_wr_wrap = addr3;
      end

      4'b1111: begin
        mem[awaddrt] = wdata[7:0];

           if((awaddrt + 1) % wboundary == 0)
           addr1 = (awaddrt + 1) - wboundary;
          else
           addr1 = awaddrt + 1;

        mem[addr1] = wdata[15:8];

         if((addr1 + 1) % wboundary == 0)
           addr2 = (addr1 + 1) - wboundary;
        else
           addr2 = addr1 + 1;

        mem[addr2] = wdata[23:16];

         if((addr2 + 1) % wboundary == 0)
           addr3 = (addr2 + 1) - wboundary;
        else
           addr3 = addr2 + 1;


        mem[addr3] = wdata[31:24];

       if((addr3 + 1) % wboundary == 0)
           addr4 = (addr3 + 1) - wboundary;
        else
           addr4 = addr3 + 1;

         data_wr_wrap = addr4;
      end
     endcase
end
  endfunction

  /////////////////// fetch data in fixed mode

function [31:0] read_data_fixed (input [31:0] addr, input [2:0] arsize);
begin
             case(arsize)
                 3'b000: begin
                  rdata[7:0] = mem[addr];
                 end

                 3'b001: begin
                  rdata[7:0]  = mem[addr];
                  rdata[15:8] = mem[addr + 1];
                 end

                 3'b010: begin
                  rdata[7:0]    = mem[addr];
                  rdata[15:8]   = mem[addr + 1];
                  rdata[23:16]  = mem[addr + 2];
                  rdata[31:24]  = mem[addr + 3];
                 end
                 endcase

                read_data_fixed = addr;
end
endfunction

//////////////////incr mode
// Signal definition - rnext_addr: next byte address calculated by the INCR read helper after the current transfer.
reg [31:0] rnext_addr = 0;
function [31:0] read_data_incr(input [31:0] addr, input [2:0] arsize);
 begin
     case(arsize)
        3'b000:
        begin
          rdata[7:0] = mem[addr];
          rnext_addr = addr + 1;
       end

       3'b001:
       begin
       rdata[7:0]  = mem[addr];
       rdata[15:8] = mem[addr + 1];
       rnext_addr  = addr + 2;
       end

       3'b010:
       begin
       rdata[7:0]    = mem[addr];
       rdata[15:8]   = mem[addr + 1];
       rdata[23:16]  = mem[addr + 2];
       rdata[31:24]  = mem[addr + 3];
       rnext_addr = addr + 4;
       end

      endcase


   read_data_incr =  rnext_addr;
 end
endfunction

 ///////////////////////////////////////////wrap mode
 // Signal definition - raddr1: first scratch byte address calculated by the WRAP read helper.
 // Signal definition - raddr2: second scratch byte address calculated by the WRAP read helper.
 // Signal definition - raddr3: third scratch byte address calculated by the WRAP read helper.
 // Signal definition - raddr4: fourth scratch byte address calculated by the WRAP read helper.
 reg [31:0] raddr1 = 0, raddr2 = 0, raddr3 = 0, raddr4 = 0;
function [31:0] read_data_wrap (input  [31:0] addr, input  [2:0] arsize, input [7:0] rboundary);
begin
   case (arsize)
     3'b000: begin
        rdata[7:0] = mem[addr];

        if(((addr + 1) % rboundary ) == 0)
               raddr1 = (addr + 1) - rboundary;
        else
               raddr1 = (addr + 1);

        read_data_wrap =  raddr1;
     end

     3'b001: begin
        rdata[7:0] = mem[addr];

         if(((addr + 1) % rboundary ) == 0)
               raddr1 = (addr + 1) - rboundary;
        else
               raddr1 = (addr + 1);

         rdata[15:8] = mem[raddr1];

         if(((raddr1 + 1) % rboundary ) == 0)
               raddr2 = (raddr1 + 1) - rboundary;
        else
               raddr2 = (raddr1 + 1);

        read_data_wrap = raddr2;
     end

     3'b010:
     begin

         rdata[7:0] = mem[addr];

         if(((addr + 1) % rboundary ) == 0)
               raddr1 = (addr + 1) - rboundary;
        else
               raddr1 = (addr + 1);

        // Lesson 124/125 retained compromise: this references write-helper
        // scratch `addr1` instead of `raddr1`, so this WRAP-read lane may use a
        // stale write address. It is documented here and not silently fixed.
        rdata[15:8] = mem[addr1];

         if(((raddr1 + 1) % rboundary ) == 0)
               raddr2 = (raddr1 + 1) - rboundary;
        else
               raddr2 = (raddr1 + 1);

         rdata[23:16]  = mem[raddr2];

        if(((raddr2 + 1) % rboundary ) == 0)
               raddr3 = (raddr2 + 1) - rboundary;
        else
               raddr3 = (raddr2 + 1);

          rdata[31:24] = mem[raddr3];

         if(((raddr3 + 1) % rboundary ) == 0)
               raddr4 = (raddr3 + 1) - rboundary;
        else
               raddr4 = (raddr3 + 1);

        // Lesson 124/125 retained compromise: the function returns write-helper
        // scratch `addr4` instead of `raddr4`; the next WRAP read address can be
        // stale or unknown for this path.
        read_data_wrap =  addr4;
     end

   endcase
  end
endfunction





// Signal definition - boundary: write-side WRAP span in bytes; the slave uses it to wrap the next write address.
// Signal definition - rboundary: read-side WRAP span in bytes; the slave uses it to wrap the next read address.
reg [7:0] boundary = 0, rboundary = 0;
// Signal definition - awlen: AXI write burst length encoded as beats minus one.
// Signal definition - arlen: AXI read burst length encoded as beats minus one.
reg [7:0] awlen = 0, arlen = 0;
// Signal definition - awsize: AXI write beat-size encoding.
// Signal definition - arsize: AXI read beat-size encoding.
reg [2:0] awsize = 0, arsize = 0;
// Signal definition - awburst: AXI write burst type encoding.
// Signal definition - arburst: AXI read burst type encoding.
reg  [1:0] awburst = 0 , arburst = 0;

always @(posedge s_axi_aclk) begin
    if (s_axi_aresetn == 0) begin
        for (i = 0; i < 128; i = i + 1) begin
            mem[i] <= 0;
        end
    end else begin
        case (state)
            idle: begin
                raddr   <= 0;
                rdata   <= 0;
                addr    <= 0;
                rboundary <= 0;
                data_write <= 0;
                awlen      <= 0;
                arlen      <= 0;
                arsize    <= 0;
                awsize    <= 0;
                arburst   <= 0;
                awburst   <= 0;
                boundary_wr <= 0;
                addr1 <= 0;
                addr2 <= 0;
                addr3 <= 0;
                addr4 <= 0;
                s_axi_awready <= 1'b0;
                s_axi_wready  <= 1'b0;
                s_axi_bid     <= 3'b000;
                s_axi_bvalid  <= 1'b0;
                s_axi_bresp   <= 2'b00;
                s_axi_arready <= 1'b0;
                s_axi_rvalid  <= 1'b0;
                s_axi_rresp   <= 2'b00;
                s_axi_rid     <= 3'b000;
                s_axi_rlast   <= 1'b0;
                s_axi_rdata   <= 32'h0;
                state         <= predict_op;
            end

            predict_op: begin
                if (s_axi_awvalid)
                    state <= accept_wr;
                else if (s_axi_arvalid)
                    state <= accept_rd;
                else
                    state <= idle;
            end

            accept_wr: begin
                if (s_axi_awaddr < 128 && ((s_axi_awaddr + s_axi_awlen*4 + 1) < 128)) begin
                    burst_len <= s_axi_awlen + 1;
                    waddr     <= s_axi_awaddr;
                    state     <= wait_wdata;
                    awlen     <= s_axi_awlen;
                    awsize    <= s_axi_awsize;
                    awburst   <= s_axi_awburst;
                    s_axi_awready <= 1'b1;
                end else begin
                    s_axi_awready <= 1'b0;
                    state <= idle;
                end
            end

            wait_wdata: begin
                s_axi_awready <= 1'b0;
                if (s_axi_wvalid) begin
                    state <= accept_wdata;
                    wdata <= s_axi_wdata;
                    wstrb <= s_axi_wstrb;
                end else if (timer == 15) begin
                    state <= write_err;
                    timer <= 0;
                end else begin
                    timer <= timer + 1;
                    state <= wait_wdata;
                end
            end

            accept_wdata: begin
                s_axi_wready <= 1'b1;
                state        <= gen_data;
            end

            gen_data: begin
                s_axi_wready <= 1'b0;
                data_write <= {(wdata[31:24] & {8{wstrb[3]}}), 24'h0} |
                              {8'h0, (wdata[23:16] & {8{wstrb[2]}}), 16'h0} |
                              {16'h0, (wdata[15:8] & {8{wstrb[1]}}), 8'h0} |
                              {24'h0, (wdata[7:0] & {8{wstrb[0]}})};
                state <= update_mem;
            end

            update_mem: begin
                if (count < 2) begin
                    count <= count + 1;
                    state <= update_mem;
                    mem[waddr] <= data_write;
                end else begin
                    burst_len <= burst_len - 1;
                    count <= 0;
                    state <= check_br_len;
                end
            end

            check_br_len: begin
                if (burst_len == 0)
                    state <= send_ack;
                else
                begin
                    state <= wait_wdata;
                    case(awburst)
                          2'b00:  ////Fixed Mode
                          begin
                          waddr <= data_wr_fixed(wstrb, waddr);  ///fixed
                          end

                          2'b01:  ////Incr mode
                          begin
                          waddr <=  data_wr_incr(wstrb,waddr);
                          end

                          2'b10:  //// wrapping
                          begin
                               boundary <= wrap_boundary(awlen, awsize);   /////calculate wrapping boundary
                               waddr    <= data_wr_wrap(wstrb, waddr, boundary); ///////generate next addr
                            end
                        endcase

                end
            end

            send_ack: begin
                if (s_axi_bready) begin
                    s_axi_bvalid <= 1'b1;
                    s_axi_bresp  <= 2'b00;
                    state        <= idle;
                end else if (timer == 15) begin
                    state <= idle;
                end else begin
                    timer <= timer + 1;
                    state <= send_ack;
                end
            end

            accept_rd: begin
                if (s_axi_araddr < 128 && ((s_axi_araddr + s_axi_arlen*4 + 1) < 128)) begin
                    rburst_len <= s_axi_arlen;
                    raddr      <= s_axi_araddr;
                    state      <= fetch_rdata;
                    arsize     <= s_axi_arsize;
                    arlen      <= s_axi_arlen;
                    arburst    <= s_axi_arburst;
                    s_axi_arready <= 1'b1;
                end else begin
                    s_axi_arready <= 1'b0;
                    state <= idle;
                end
            end

            fetch_rdata: begin
                s_axi_arready <= 1'b0;

                if (count < 2) begin
                    count <= count + 1;
                    state <= fetch_rdata;
                    rdata <= mem[raddr];
                end else begin
                    count <= 0;
                    state <= send_rdata;
                end
            end

            send_rdata: begin
                s_axi_rvalid <= 1'b1;
                s_axi_rdata  <= rdata;
                s_axi_rresp  <= 2'b00;
                if (s_axi_rready) begin
                    state <= rcheck_br_len;
                end else if (timer == 15) begin
                    state <= idle;
                    timer <= 0;
                end else begin
                    state <= send_rdata;
                    timer <= timer + 1;
                end
            end

            rcheck_br_len: begin
                rburst_len <= rburst_len - 1;
                s_axi_rvalid <= 1'b0;
                case(arburst)
                2'b00: begin
                raddr <= read_data_fixed(raddr,arsize);
                end
                2'b01:begin
                raddr <= read_data_incr(raddr, arsize);
                end
                2'b10: begin
                rboundary  <=  wrap_boundary(arlen,arsize);
                raddr      <=  read_data_wrap(raddr, arsize, rboundary);
                end
                endcase

                if (rburst_len == 1) begin
                    state <= fetch_ldata;
                end else begin
                    state <= fetch_rdata;
                end
            end

            fetch_ldata: begin

                if (count < 2) begin
                    count <= count + 1;
                    state <= fetch_ldata;
                    rdata <= mem[raddr];
                end else begin
                    count <= 0;
                    state <= send_rlast;
                    s_axi_rvalid <= 1'b1;
                    s_axi_rdata  <= rdata;
                    s_axi_rresp  <= 2'b00;
                    s_axi_rlast  <= 1'b1;
                end
            end

            send_rlast:
            begin
                if (s_axi_rready == 1'b1)
                begin
                    state        <= idle;
                    s_axi_rvalid <= 1'b0;
                    s_axi_rdata  <= 0;
                    s_axi_rresp  <= 2'b00;
                    s_axi_rlast  <= 1'b0;
                    timer        <= 0;
                end else if (timer == 15) begin
                    state <= idle;
                    timer <= 0;
                end else begin
                    state <= send_rlast;
                    timer <= timer + 1;
                end
            end


            default: state <= idle;
        endcase
    end
end


endmodule
