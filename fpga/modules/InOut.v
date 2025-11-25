/**
 * The module InOut is a bidirectional I/O buffer
 * Uses SB_IO primitive for FPGA pin control
 */
`default_nettype none
module InOut(
    // Pin Interface
    inout PIN,

    // Control Interface
    input dir,

    // Data Interface
    input dataW,
    output dataR
);

    // Module instantiations
    
    // SB_IO instantiation for bi-directional pin
    SB_IO #(
        .PIN_TYPE(6'b1010_01)
    ) io_pin (
        .PACKAGE_PIN(PIN),
        .OUTPUT_ENABLE(dir),
        .D_OUT_0(dataW),
        .D_IN_0(dataR)
    );

endmodule
