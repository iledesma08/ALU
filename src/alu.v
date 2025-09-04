`default_nettype none // Le decimos al compilador que no cree wires implícitos (tirar error si se escribe mal el nombre de una señal en lugar de hacer un wire)
                      // Por defecto, esto sería `default_nettype wire

module alu #(
    parameter NB_DATA = 8, // Ancho de datos, por defecto 8 bits
    parameter NB_OP = 6   // Ancho de la operacion, por defecto 6 bits
                          // Si bien los códigos ya estan establecidos, puedo aumentar esto y agregar mas operaciones en una instancia futura
) (
    input wire [NB_DATA-1:0] i_a, i_b,
    input wire [NB_OP-1:0] i_op,
    output reg [NB_DATA-1:0] o_result,
    output reg o_zero, o_overflow
);

    // OPERACIONES

    // Aritmeticas
    localparam OP_ADD = 6'b100000; // A + B
    localparam OP_SUB = 6'b100010; // A - B

    // Logicas
    localparam OP_AND = 6'b100100; // A & B
    localparam OP_OR  = 6'b100101; // A | B
    localparam OP_XOR = 6'b100110; // A ^ B
    localparam OP_NOR = 6'b100111; // ~(A | B)

    // Shifts (solo A, B no se usa)
    localparam OP_SRA = 6'b000011; // A >> 1 -> aritmetico (llenando con el MSB, el bit de signo)
    localparam OP_SRL = 6'b000010; // A >>> 1 -> logico (llenando con 0s)

    always @(*) begin
        // Valores por defecto antes de realizar una operacion
        // Todas las salidas tienen un valor definido, incluso si alguna operacion no esta implementada
        o_result = {NB_DATA{1'b0}};
        o_zero = 1'b0;
        o_overflow = 1'b0;

        case (i_op)
            OP_ADD: begin
                {o_overflow, o_result} = {1'b0, i_a} + {1'b0, i_b}; // Concateno un bit extra para detectar overflow
            end
            OP_SUB: begin
                {o_overflow, o_result} = {1'b0, i_a} - {1'b0, i_b}; // Concateno un bit extra para detectar underflow
                                                                    // (sirve para detectar mayor que o menor que)
            end
            OP_AND: begin
                o_result = i_a & i_b;
            end
            OP_OR: begin
                o_result = i_a | i_b;
            end
            OP_XOR: begin
                o_result = i_a ^ i_b;
            end
            OP_NOR: begin
                o_result = ~(i_a | i_b);
            end
            OP_SRA: begin
                o_result = {i_a[NB_DATA-1], i_a[NB_DATA-1:1]}; // Relleno con el MSB (bit de signo)
            end
            OP_SRL: begin
                o_result = {1'b0, i_a[NB_DATA-1:1]}; // Relleno con 0s
            end
            default: begin
                // Operacion no definida, resultado en 0 y flags en 0 (valores por defecto)
            end
        endcase

        // Flag zero
        if (o_result == {NB_DATA{1'b0}}) begin
            o_zero = 1'b1;
        end
    end

endmodule

`default_nettype wire
