`timescale 1ns/1ps

module tb_top;

    // Parámetros
    localparam NB_DATA = 8;
    localparam NB_OP = 6;
    
    // Códigos de operación - deben coincidir con los de la ALU
    localparam OP_ADD = 6'b100000;
    localparam OP_SUB = 6'b100010;
    localparam OP_AND = 6'b100100;
    localparam OP_OR  = 6'b100101;
    localparam OP_XOR = 6'b100110;
    localparam OP_NOR = 6'b100111;
    localparam OP_SRA = 6'b000011;
    localparam OP_SRL = 6'b000010;

    // Array de operaciones para selección aleatoria
    reg [NB_OP-1:0] operations [0:7];

    // Señales del DUT
    reg i_clk, i_rst, i_en_A, i_en_B, i_en_OP;
    reg [NB_DATA-1:0] i_data_a, i_data_b;
    reg [NB_OP-1:0] i_op;
    wire [NB_DATA-1:0] o_result;
    wire o_zero, o_overflow;

    // Variables para el proceso principal
    reg [NB_DATA-1:0] test_a, test_b;
    reg [NB_OP-1:0] test_op;
    
    // Contadores para estadísticas
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;

    // Variables para cálculo de resultado esperado
    reg [NB_DATA:0] expected_full;
    reg [NB_DATA-1:0] expected_result;
    reg expected_zero, expected_overflow;

    // Instancia del DUT
    top #(
        .NB_DATA(NB_DATA),
        .NB_OP(NB_OP)
    ) dut (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_en_A(i_en_A),
        .i_en_B(i_en_B),
        .i_en_OP(i_en_OP),
        .i_data_a(i_data_a),
        .i_data_b(i_data_b),
        .i_op(i_op),
        .o_result(o_result),
        .o_zero(o_zero),
        .o_overflow(o_overflow)
    );

    // Generador de reloj
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;  // Periodo de 10ns
    end

    // Inicializar array de operaciones
    initial begin
        operations[0] = OP_ADD;
        operations[1] = OP_SUB;
        operations[2] = OP_AND;
        operations[3] = OP_OR;
        operations[4] = OP_XOR;
        operations[5] = OP_NOR;
        operations[6] = OP_SRA;
        operations[7] = OP_SRL;
    end

    // Function para calcular resultado esperado
    function [NB_DATA:0] calculate_expected;
        input [NB_DATA-1:0] a, b;
        input [NB_OP-1:0] op;
        begin
            case (op)
                OP_ADD: calculate_expected = {1'b0, a} + {1'b0, b};
                OP_SUB: calculate_expected = {1'b0, a} - {1'b0, b};
                OP_AND: calculate_expected = {1'b0, a & b};
                OP_OR:  calculate_expected = {1'b0, a | b};
                OP_XOR: calculate_expected = {1'b0, a ^ b};
                OP_NOR: calculate_expected = {1'b0, ~(a | b)};
                OP_SRA: calculate_expected = {1'b0, {a[NB_DATA-1], a[NB_DATA-1:1]}};
                OP_SRL: calculate_expected = {1'b0, {1'b0, a[NB_DATA-1:1]}};
                default: calculate_expected = 0;
            endcase
        end
    endfunction

    // Task para mostrar nombre de operación
    task display_op_name;
        input [NB_OP-1:0] op;
        begin
            case (op)
                OP_ADD: $write("ADD");
                OP_SUB: $write("SUB");
                OP_AND: $write("AND");
                OP_OR:  $write("OR");
                OP_XOR: $write("XOR");
                OP_NOR: $write("NOR");
                OP_SRA: $write("SRA");
                OP_SRL: $write("SRL");
                default: $write("UNK");
            endcase
        end
    endtask

    // Task para verificar resultado
    task verify_result;
        input [NB_DATA-1:0] a, b;
        input [NB_OP-1:0] op;
        begin
            // Calcular resultado esperado
            expected_full = calculate_expected(a, b, op);
            expected_result = expected_full[NB_DATA-1:0];
            expected_overflow = expected_full[NB_DATA];
            expected_zero = (expected_result == 0) ? 1'b1 : 1'b0;
            
            test_count = test_count + 1;
            
            // Verificar resultado
            if (o_result === expected_result && 
                o_zero === expected_zero && 
                o_overflow === expected_overflow) begin
                
                // Test PASS
                pass_count = pass_count + 1;
                $write("PASS [%0d] - ", test_count);
                display_op_name(op);
                $display(": A=%0d, B=%0d -> Result=%0d (zero=%b, overflow=%b)", 
                        a, b, o_result, o_zero, o_overflow);
                        
            end else begin
                // Test FAIL
                fail_count = fail_count + 1;
                $write("FAIL [%0d] - ", test_count);
                display_op_name(op);
                $display(": A=%0d, B=%0d", a, b);
                $display("    Expected: result=%0d, zero=%b, overflow=%b", 
                        expected_result, expected_zero, expected_overflow);
                $display("    Got:      result=%0d, zero=%b, overflow=%b", 
                        o_result, o_zero, o_overflow);
            end
        end
    endtask

    // Task para cargar operandos y operación usando sincronización con clock
    task load_and_test;
        reg [2:0] op_index;
        begin
            // Generar datos aleatorios
            test_a = $random;
            test_b = $random;
            op_index = $random % 8;  // Seleccionar operación aleatoria
            test_op = operations[op_index];
            
            // Cargar A sincronizado con clock
            @(negedge i_clk);  // Cambiar datos en flanco negativo
            i_data_a = test_a;
            i_en_A = 1'b1;
            @(posedge i_clk);  // Esperar flanco positivo para que el registro capture
            @(negedge i_clk);  // Cambiar enable en flanco negativo
            i_en_A = 1'b0;
            
            // Cargar B sincronizado con clock
            @(negedge i_clk);
            i_data_b = test_b;
            i_en_B = 1'b1;
            @(posedge i_clk);
            @(negedge i_clk);
            i_en_B = 1'b0;
            
            // Cargar OP sincronizado con clock
            @(negedge i_clk);
            i_op = test_op;
            i_en_OP = 1'b1;
            @(posedge i_clk);
            @(negedge i_clk);
            i_en_OP = 1'b0;
            
            // Esperar un ciclo adicional para que la ALU procese
            @(posedge i_clk);
            @(negedge i_clk);
            
            // Verificar resultado
            verify_result(test_a, test_b, test_op);
        end
    endtask

    // Task para mostrar resumen final
    task show_summary;
        real success_rate;
        begin
            success_rate = (test_count > 0) ? (pass_count * 100.0) / test_count : 0.0;
            
            $display("\n==================================================");
            $display("RESUMEN DE SIMULACIÓN");
            $display("==================================================");
            $display("Tests ejecutados: %0d", test_count);
            $display("Tests pasados:    %0d", pass_count);
            $display("Tests fallidos:   %0d", fail_count);
            $display("Tasa de éxito:    %0.1f%%", success_rate);
            
            if (fail_count == 0) begin
                $display("\n✓ TODOS LOS TESTS PASARON!");
            end else begin
                $display("\n✗ HAY TESTS FALLIDOS");
            end
            $display("==================================================");
        end
    endtask

    // Proceso principal de simulación
    initial begin
        $display("============================================================");
        $display("TESTBENCH para módulo TOP - ALU con registros");
        $display("============================================================");
        $display("Parámetros: NB_DATA=%0d, NB_OP=%0d", NB_DATA, NB_OP);
        $display("Operaciones soportadas: ADD, SUB, AND, OR, XOR, NOR, SRA, SRL");
        $display("============================================================");
        
        // Inicialización
        i_rst = 1'b1;
        i_en_A = 1'b0;
        i_en_B = 1'b0;
        i_en_OP = 1'b0;
        i_data_a = 0;
        i_data_b = 0;
        i_op = 0;
        
        // Aplicar reset
        $display("\nAplicando reset...");
        repeat(3) @(posedge i_clk);
        i_rst = 1'b0;
        @(posedge i_clk);
        $display("Reset completado.\n");

        // Ejecutar tests aleatorios
        $display("Iniciando tests con datos aleatorios...\n");
        repeat(50) begin  // Ejecutar 50 tests aleatorios
            load_and_test();
        end

        // Mostrar resumen final
        show_summary();
        
        $display("\nSimulación completada.");
        $finish;
    end

endmodule
