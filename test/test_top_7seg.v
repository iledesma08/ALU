`timescale 1ns / 1ps

module test_top_7seg;

    // Parámetros del DUT
    parameter NB_DATA = 8;
    parameter NB_OP = 6;
    parameter CLK_PERIOD = 10; // 100MHz

    // Señales del testbench
    reg i_clk, i_rst, i_en_A, i_en_B, i_en_OP;
    reg [NB_DATA-1:0] i_data;
    wire [NB_DATA-1:0] o_result;
    wire o_zero, o_overflow;
    wire [6:0] o_seg;
    wire [3:0] o_an;

    // Instancia del DUT
    top #(
        .NB_DATA(NB_DATA),
        .NB_OP(NB_OP)
    ) uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en_A(i_en_A),
        .i_en_B(i_en_B),
        .i_en_OP(i_en_OP),
        .i_data(i_data),
        .o_result(o_result),
        .o_zero(o_zero),
        .o_overflow(o_overflow),
        .o_seg(o_seg),
        .o_an(o_an)
    );

    // Generador de clock
    initial begin
        i_clk = 1'b0;
        forever #(CLK_PERIOD/2) i_clk = ~i_clk;
    end

    // Códigos de operación
    localparam OP_ADD = 6'b100000;
    localparam OP_SUB = 6'b100010;
    localparam OP_AND = 6'b100100;
    localparam OP_OR  = 6'b100101;

    // Estímulos
    initial begin
        $dumpfile("test_top_7seg.vcd");
        $dumpvars(0, test_top_7seg);

        // Inicialización
        i_rst = 1'b1;
        i_en_A = 1'b0;
        i_en_B = 1'b0;
        i_en_OP = 1'b0;
        i_data = 8'h00;

        // Reset
        #(CLK_PERIOD * 2);
        i_rst = 1'b0;
        #(CLK_PERIOD);

        $display("=== Prueba de ALU con Displays de 7 Segmentos ===");

        // Prueba 1: 123 + 45 = 168
        test_operation(123, 45, OP_ADD, "123 + 45");
        #(CLK_PERIOD * 1000); // Tiempo para observar multiplexado

        // Prueba 2: 200 - 150 = 50
        test_operation(200, 150, OP_SUB, "200 - 150");
        #(CLK_PERIOD * 1000);

        // Prueba 3: 50 - 100 = -50 (prueba de número negativo)
        test_operation(50, 100, OP_SUB, "50 - 100 (negativo)");
        #(CLK_PERIOD * 1000);

        // Prueba 4: 255 & 15 = 15 (operación lógica)
        test_operation(255, 15, OP_AND, "255 & 15");
        #(CLK_PERIOD * 1000);

        // Prueba 5: 0 + 0 = 0 (flag zero)
        test_operation(0, 0, OP_ADD, "0 + 0 (zero flag)");
        #(CLK_PERIOD * 1000);

        $display("=== Fin de las pruebas ===");
        $finish;
    end

    // Tarea para realizar una operación completa
    task test_operation;
        input [7:0] a, b;
        input [5:0] op;
        input [200*8:1] description;
        begin
            $display("Ejecutando: %s", description);
            
            // Cargar operando A
            i_data = a;
            i_en_A = 1'b1;
            #(CLK_PERIOD);
            i_en_A = 1'b0;
            
            // Cargar operando B
            i_data = b;
            i_en_B = 1'b1;
            #(CLK_PERIOD);
            i_en_B = 1'b0;
            
            // Cargar operación
            i_data = {2'b00, op};
            i_en_OP = 1'b1;
            #(CLK_PERIOD);
            i_en_OP = 1'b0;
            
            // Esperar un ciclo para que se propague el resultado
            #(CLK_PERIOD);
            
            $display("  A=%d, B=%d, OP=%b", a, b, op);
            $display("  Resultado binario: %b (%d)", o_result, o_result);
            $display("  Zero: %b, Overflow: %b", o_zero, o_overflow);
            $display("  ----");
        end
    endtask

    // Monitor para observar cambios en los displays
    always @(posedge i_clk) begin
        if (!i_rst) begin
            // Solo mostrar cada cierto tiempo para no saturar la salida
            if ($time % (CLK_PERIOD * 100) == 0) begin
                $display("Time: %t, Display AN: %b, SEG: %b", $time, o_an, o_seg);
            end
        end
    end

endmodule
