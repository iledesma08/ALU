`default_nettype none

// Control de multiplexado para displays de 7 segmentos
module display_mux #(
    parameter NB_DISPLAYS = 4,  // Número de displays
    parameter COUNTER_BITS = 17 // Bits del contador para refrescar (~750Hz @ 100MHz)
) (
    input wire i_clk,
    input wire i_rst,
    input wire [6:0] i_seg0, i_seg1, i_seg2, i_seg3,  // Segmentos de cada display
    output reg [6:0] o_seg,                            // Segmentos multiplexados
    output reg [NB_DISPLAYS-1:0] o_an                  // Ánodos de displays
);

    reg [COUNTER_BITS-1:0] counter;
    wire [1:0] display_select;
    
    assign display_select = counter[COUNTER_BITS-1:COUNTER_BITS-2];

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end

    always @(*) begin
        case (display_select)
            2'b00: begin
                o_seg = i_seg0;
                o_an = 4'b1110;  // Activa display 0 (activo bajo)
            end
            2'b01: begin
                o_seg = i_seg1;
                o_an = 4'b1101;  // Activa display 1
            end
            2'b10: begin
                o_seg = i_seg2;
                o_an = 4'b1011;  // Activa display 2
            end
            2'b11: begin
                o_seg = i_seg3;
                o_an = 4'b0111;  // Activa display 3
            end
            default: begin
                o_seg = 7'b1111111;
                o_an = 4'b1111;
            end
        endcase
    end

endmodule

`default_nettype wire
