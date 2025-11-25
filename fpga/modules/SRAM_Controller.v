/**
 * The module SRAM_Controller is an SRAM memory controller
 * Controls read/write operations to external SRAM
 * Manages tri-state data bus and control signals
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

    // Data Interface (bidirectional)
    inout wire [15:0] DATA,

    // SRAM Control Signals
    output wire CSX,
    output wire OEX,
    output wire WEX
);

    // Internal signals
    reg [15:0] data_reg;
    reg data_dir;

    // Initial blocks
    
    initial begin
        data_reg = 16'b0;
        data_dir = 0;
    end

    // Combinational logic
    
    // Tri-state buffer control
    assign DATA = (data_dir) ? data_reg : 16'bz;

    // Control signals
    assign CSX = 0;     // Always enabled (active low)
    assign OEX = ~WE;   // Output Enable when reading (active low)
    assign WEX = WE;    // Write Enable (active low)

    // Sequential logic
    
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            data_reg <= 16'b0;
            data_dir <= 0;
        end else begin
            if (WE) begin
                // Write operation
                data_reg <= DATA;
                data_dir <= 1; // Set DATA bus direction to write
            end else begin
                // Read operation
                data_dir <= 0; // Set DATA bus direction to read
            end
        end
    end

endmodule
