`default_nettype none

module top #(
    parameter NB_DATA = 8, // Ancho de datos, por defecto 8 bits
    parameter NB_OP = 6    // Ancho de la operacion, por defecto 6 bits
) (
    input wire i_clk, i_rst, i_en_A, i_en_B, i_en_OP,
    input wire [NB_DATA-1:0] i_data, // Una sola entrada de datos de 8 bits
    output wire [NB_DATA-1:0] o_result,
    output wire o_zero, o_overflow
);

    // Señales intermedias para conectar registros con ALU
    wire [NB_DATA-1:0] reg_a_out, reg_b_out;
    wire [NB_OP-1:0] reg_op_out;

    // Registros para almacenar los operandos y la operacion
    // Se podría mejorar si hay más registros usando un generate, pero por ahora está bien así
    base_reg #(
        .NB_DATA(NB_DATA) // Ancho de datos del registro
    ) u_reg_a (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(i_en_A),
        .i_data(i_data), // Misma entrada de datos
        .o_data(reg_a_out) // Salida conectada a señal interna
    );

    base_reg #(
        .NB_DATA(NB_DATA) // Ancho de datos del registro
    ) u_reg_b (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(i_en_B),
        .i_data(i_data), // Misma entrada de datos
        .o_data(reg_b_out) // Salida conectada a señal interna
    );

    base_reg #(
        .NB_DATA(NB_OP) // Ancho de datos del registro (operacion)
    ) u_reg_op (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en(i_en_OP),
        .i_data(i_data[NB_OP-1:0]), // Solo toma los 6 LSB de los 8 bits de entrada
        .o_data(reg_op_out) // Salida conectada a señal interna
    );

    // Instancio la ALU
    alu #(
        .NB_DATA(NB_DATA), // Ancho de datos de la ALU
        .NB_OP(NB_OP)      // Ancho de operacion de la ALU
    ) u_alu (
        .i_a(reg_a_out),    // Conectado a la salida del registro A
        .i_b(reg_b_out),    // Conectado a la salida del registro B
        .i_op(reg_op_out),  // Conectado a la salida del registro OP
        .o_result(o_result),
        .o_zero(o_zero),
        .o_overflow(o_overflow)
    );

endmodule

`default_nettype wire
