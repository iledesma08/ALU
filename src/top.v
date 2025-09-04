`default_nettype none

module top #(
    parameter NB_DATA = 8, // Ancho de datos, por defecto 8 bits
    parameter NB_OP = 6    // Ancho de la operacion, por defecto 6 bits
) (
    input wire i_clk, i_rst, i_en_A, i_en_B, i_en_OP,
    input wire [NB_DATA-1:0] i_data, // Una sola entrada de datos de 8 bits
    output wire [NB_DATA-1:0] o_result,
    output wire o_zero, o_overflow,
    // Salidas para displays de 7 segmentos
    output wire [6:0] o_seg,        // Segmentos a-g
    output wire [3:0] o_an          // Ánodos de displays (activo bajo)
);

    // Señales intermedias para conectar registros con ALU
    wire [NB_DATA-1:0] reg_a_out, reg_b_out;
    wire [NB_OP-1:0] reg_op_out;
    
    // Señales para displays de 7 segmentos
    wire [11:0] bcd_result;     // 3 dígitos BCD (12 bits)
    wire negative_result;       // Indica si el resultado es negativo
    wire [6:0] seg0, seg1, seg2, seg3;  // Segmentos para cada display
    wire is_arithmetic_op;      // Indica si la operación es aritmética (suma/resta)
    
    // Determinar si la operación actual es aritmética (para manejo de signo)
    assign is_arithmetic_op = (reg_op_out == 6'b100000) || (reg_op_out == 6'b100010); // ADD o SUB

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

    // Conversor binario a BCD
    bin_to_bcd #(
        .NB_DATA(NB_DATA),
        .NB_BCD(12)
    ) u_bin_to_bcd (
        .i_bin(o_result),
        .i_sign(is_arithmetic_op),  // Solo considerar signo en operaciones aritméticas
        .o_bcd(bcd_result),
        .o_negative(negative_result)
    );

    // Decodificadores BCD a 7 segmentos para cada dígito
    bcd_to_7seg u_bcd_to_7seg_0 (  // Unidades
        .i_bcd(bcd_result[3:0]),
        .i_enable(1'b1),
        .o_seg(seg0)
    );

    bcd_to_7seg u_bcd_to_7seg_1 (  // Decenas
        .i_bcd(bcd_result[7:4]),
        .i_enable(|bcd_result[11:4]),  // Habilitar solo si hay valor en decenas o centenas
        .o_seg(seg1)
    );

    bcd_to_7seg u_bcd_to_7seg_2 (  // Centenas
        .i_bcd(bcd_result[11:8]),
        .i_enable(|bcd_result[11:8]), // Habilitar solo si hay valor en centenas
        .o_seg(seg2)
    );

    // Display para signo - muestra "-" si es negativo, apagado si es positivo
    assign seg3 = negative_result ? 7'b0111111 : 7'b1111111; // "-" o apagado

    // Multiplexor para displays
    display_mux #(
        .NB_DISPLAYS(4),
        .COUNTER_BITS(17)
    ) u_display_mux (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_seg0(seg0),  // Unidades
        .i_seg1(seg1),  // Decenas  
        .i_seg2(seg2),  // Centenas
        .i_seg3(seg3),  // Signo
        .o_seg(o_seg),
        .o_an(o_an)
    );

endmodule

`default_nettype wire
