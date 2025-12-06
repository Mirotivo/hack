/**
 * The module SRAM_Controller is an SRAM memory controller
 * Controls read/write operations to external SRAM
 * Manages tri-state data bus using ICE40 SB_IO primitives
 * NOTE: This module contains SB_IO and must be connected directly to top-level inout ports
 */
`default_nettype none
module SRAM_Controller (
    // Clock and Reset
    input wire CLK,
    input wire RST,

    // Control Interface
    input wire WE,

    // Address Interface
    input wire [17:0] ADDRESS,

    // Data Interface (bidirectional - connects directly to FPGA pins)
    inout wire [15:0] DATA,

    // Data from/to internal logic
    input wire [15:0] DATA_WRITE,       // Data to write to SRAM
    output reg [15:0] DATA_READ,        // Data read from SRAM

    // SRAM Control Signals
    output wire CSX,
    output wire OEX,
    output wire WEX
);

    // --------------------------
    // Internal signals
    // --------------------------
    wire [15:0] data_from_pin;

    // --------------------------
    // Module instantiations
    // --------------------------
    
    // ICE40 Bidirectional I/O primitives
    // Each DATA bit needs its own SB_IO instance
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : sram_io
            SB_IO #(
                .PIN_TYPE(6'b1010_01),  // Tristate output (1010), input (01)
                .PULLUP(1'b0)            // No pullup
            ) sb_io_inst (
                .PACKAGE_PIN(DATA[i]),              // Physical FPGA pin
                .OUTPUT_ENABLE(WE),                 // Drive when WE=1 (writing)
                .D_OUT_0(DATA_WRITE[i]),           // Data to output to pin
                .D_IN_0(data_from_pin[i])          // Data input from pin
            );
        end
    endgenerate

    // --------------------------
    // Combinational logic
    // --------------------------
    
    // Control signals
    assign CSX = 0;     // Always enabled (active low)
    assign OEX = WE;    // Output Enable: HIGH during write, LOW during read
    assign WEX = ~WE;   // Write Enable: LOW during write, HIGH during read

    // --------------------------
    // Sequential logic
    // --------------------------
    
    initial begin
        DATA_READ = 16'b0;
    end
    
    // Capture read data from SRAM
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            DATA_READ <= 16'b0;
        end else begin
            if (!WE) begin
                // Read operation - capture data from SRAM
                DATA_READ <= data_from_pin;
            end
        end
    end

endmodule
