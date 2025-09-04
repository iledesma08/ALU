`default_nettype none

// Módulo para convertir binario a BCD usando el algoritmo Double Dabble
module bin_to_bcd #(
    parameter NB_DATA = 8,  // Ancho de entrada en bits
    parameter NB_BCD = 12   // Ancho de salida BCD (3 dígitos = 12 bits)
) (
    input wire [NB_DATA-1:0] i_bin,
    input wire i_sign,                      // 1 si el número es negativo
    output reg [NB_BCD-1:0] o_bcd,
    output reg o_negative                   // Salida que indica si es negativo
);

    integer i;
    reg [NB_DATA+NB_BCD-1:0] temp;
    reg [NB_DATA-1:0] abs_bin;

    always @(*) begin
        // Determinar si el número es negativo y obtener valor absoluto
        if (i_sign && i_bin[NB_DATA-1]) begin
            o_negative = 1'b1;
            abs_bin = ~i_bin + 1'b1;  // Complemento a 2
        end else begin
            o_negative = 1'b0;
            abs_bin = i_bin;
        end
        
        // Inicializar temp con el valor absoluto en los bits menos significativos
        temp = {{NB_BCD{1'b0}}, abs_bin};
        
        // Algoritmo Double Dabble
        for (i = 0; i < NB_DATA; i = i + 1) begin
            // Revisar cada dígito BCD y sumar 3 si es >= 5
            if (temp[NB_DATA+3:NB_DATA] >= 5)
                temp[NB_DATA+3:NB_DATA] = temp[NB_DATA+3:NB_DATA] + 3;
            if (temp[NB_DATA+7:NB_DATA+4] >= 5)
                temp[NB_DATA+7:NB_DATA+4] = temp[NB_DATA+7:NB_DATA+4] + 3;
            if (temp[NB_DATA+11:NB_DATA+8] >= 5)
                temp[NB_DATA+11:NB_DATA+8] = temp[NB_DATA+11:NB_DATA+8] + 3;
                
            // Shift izquierda
            temp = temp << 1;
        end
        
        // Extraer resultado BCD
        o_bcd = temp[NB_DATA+NB_BCD-1:NB_DATA];
    end

endmodule

`default_nettype wire
