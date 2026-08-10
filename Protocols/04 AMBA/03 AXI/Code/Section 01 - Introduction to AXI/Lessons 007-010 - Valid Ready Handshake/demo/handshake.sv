/*
 * REVISION ATLAS - INSTRUCTOR COURSE CODE (COMMENTS ADDED ONLY)
 * Section 01: Introduction to AXI
 * Lecture path: Lessons 7-10 - Valid/Ready Handshake
 * Downloadable source page: Lesson 010
 * Module: handshake
 * Role: Combined simulation demonstration
 *
 * PRESERVATION:
 * - Module name, port/signal names, architecture, state flow, and executable
 *   statements are the instructor's. The repository adds comments and splits
 *   multi-module lesson blocks into named files only.
 *
 * ASSUMPTIONS:
 * - The module supplies its own clock and active-LOW reset stimulus.
 * - The source creates payload with $urandom_range, so this is a simulation demonstration rather than reusable synthesizable RTL.
 * - The receiver has one visible data register and one processing state.
 *
 * USED / OMITTED / SIMPLIFIED:
 * - This is generic VALID/READY teaching logic, not a complete AXI-Stream interface.
 * - AXI-Stream sidebands TKEEP, TSTRB, TLAST, TID, TDEST, and TUSER are absent.
 *
 * BEHAVIORAL CONSEQUENCE:
 * - Use the module to trace handshake timing; do not instantiate it as production IP.
 * - The payload changes only through the instructor's state sequence.
 */
`timescale 1ns / 1ps

module handshake();

// State/control definition - new_data: source-FSM state that generates a new payload and asserts VALID.
// State/control definition - wait_for_slave: source-FSM state that holds VALID/data while waiting for receiver READY.
localparam new_data = 0, wait_for_slave = 1;
// State/control definition - wait_for_data: receiver-FSM state that asserts READY and waits for source VALID.
// State/control definition - process_data: receiver-FSM state entered after capturing one accepted payload.
localparam wait_for_data = 0, process_data = 1;

// Signal definition - m_state: current state of the handshake demonstration's source FSM.
// Signal definition - s_state: current state of the handshake demonstration's receiver FSM.
reg m_state = 0,s_state = 0;

// Signal definition - m_data: source-side payload register held while waiting for receiver readiness.
// Signal definition - s_data: receiver-side register that captures the accepted source payload.
reg [7:0] m_data,s_data;
// Signal definition - m_validout: generic source VALID flag for the handshake demonstration.
reg m_validout;
// Signal definition - s_readyout: generic receiver READY flag for the handshake demonstration.
reg s_readyout;
// Signal definition - rstn: active-LOW reset used by the course state and output logic.
reg rstn;
// Signal definition - clk: clock used to sample the course FSM and interface handshakes on rising edges.
reg clk = 0;

always #10 clk = ~clk;

initial begin
rstn = 0;
repeat(10) @(posedge clk);
rstn = 1;
end

//////////// master logic

always@(posedge clk)
begin
  if(rstn==1'b0)
    begin
    m_data <= 0;
    m_validout <= 0;
    end
  else
   begin
    case(m_state)
    new_data:
        begin
           m_data <= $urandom_range(0,15);
           m_validout <= 1'b1;
           m_state      <= wait_for_slave;
        end

    wait_for_slave:
        begin
           if(s_readyout)
             begin
             m_state <= new_data;
             m_validout <= 1'b0;
             end
           else
             m_state <= wait_for_slave;
        end
    endcase
   end
end

/////////////////////// slave logic

always@(posedge clk)
begin
  if(rstn==1'b0)
    begin
    s_data     <= 0;
    s_readyout <= 0;
    end
  else
   begin
    case(s_state)
    wait_for_data:
        begin
            s_readyout <= 1'b1;
            if(m_validout == 1'b1)
               begin
               s_state     <= process_data;
               s_readyout <= 1'b0;
               s_data      <= m_data;
               end
            else
               s_state <= wait_for_data;
        end
    process_data:
        begin
            s_state <= wait_for_data;
            s_readyout <= 1'b1;
        end
    endcase
   end
end



endmodule
