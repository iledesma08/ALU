`default_nettype none

module base_reg #(
    parameter NB_DATA = 8 // Ancho de datos, por defecto 8 bits
) (
    input wire i_clk, i_rst, i_en,
    input wire [NB_DATA-1:0] i_data,
    output reg [NB_DATA-1:0] o_data
);

    always @(posedge i_clk) begin
        if (i_rst) begin
            o_data <= {NB_DATA{1'b0}};
        end else if (i_en) begin
            o_data <= i_data;
        end
    end

endmodule

`default_nettype wire
