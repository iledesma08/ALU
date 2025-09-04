`default_nettype none

// Decoder BCD a 7 segmentos (ánodo común)
module bcd_to_7seg (
    input wire [3:0] i_bcd,
    input wire i_enable,        // Enable para el display
    output reg [6:0] o_seg      // Segmentos a-g (activo bajo)
);

    always @(*) begin
        if (!i_enable) begin
            o_seg = 7'b1111111; // Todos los segmentos apagados
        end else begin
            case (i_bcd)
                4'h0: o_seg = 7'b1000000; // 0
                4'h1: o_seg = 7'b1111001; // 1
                4'h2: o_seg = 7'b0100100; // 2
                4'h3: o_seg = 7'b0110000; // 3
                4'h4: o_seg = 7'b0011001; // 4
                4'h5: o_seg = 7'b0010010; // 5
                4'h6: o_seg = 7'b0000010; // 6
                4'h7: o_seg = 7'b1111000; // 7
                4'h8: o_seg = 7'b0000000; // 8
                4'h9: o_seg = 7'b0010000; // 9
                default: o_seg = 7'b1111111; // Apagado
            endcase
        end
    end

endmodule

`default_nettype wire
