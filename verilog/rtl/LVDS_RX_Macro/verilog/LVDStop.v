   module LVDStop (
`ifdef USE_POWER_PINS
    inout VDD,
    inout GND,
`endif
    input C1,
    input INP,
    input INN,
    input VBIASN,
    output OUT,
);

endmodule