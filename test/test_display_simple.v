`timescale 1ns / 1ps

// Testbench simple para verificar display individual
module test_display_simple;

    reg [7:0] test_value;
    wire [11:0] bcd_out;
    wire negative;
    wire [6:0] seg0, seg1, seg2, seg3;

    // Instanciar conversor BCD
    bin_to_bcd #(
        .NB_DATA(8),
        .NB_BCD(12)
    ) uut_bcd (
        .i_bin(test_value),
        .i_sign(1'b1), // Habilitamos detección de signo
        .o_bcd(bcd_out),
        .o_negative(negative)
    );

    // Instanciar decodificadores
    bcd_to_7seg dec0 (.i_bcd(bcd_out[3:0]),   .i_enable(1'b1), .o_seg(seg0));
    bcd_to_7seg dec1 (.i_bcd(bcd_out[7:4]),   .i_enable(|bcd_out[11:4]), .o_seg(seg1));
    bcd_to_7seg dec2 (.i_bcd(bcd_out[11:8]),  .i_enable(|bcd_out[11:8]), .o_seg(seg2));
    
    assign seg3 = negative ? 7'b0111111 : 7'b1111111; // "-" o apagado

    initial begin
        $dumpfile("test_display_simple.vcd");
        $dumpvars(0, test_display_simple);

        $display("=== Test Simple de Conversión a Display ===");
        
        // Valores de prueba
        test_values(0);      // 0
        test_values(7);      // 7  
        test_values(15);     // 15
        test_values(99);     // 99
        test_values(123);    // 123
        test_values(255);    // 255
        test_values(8'b11001110); // -50 en complemento a 2
        
        $display("=== Fin del test ===");
        $finish;
    end

    task test_values;
        input [7:0] val;
        begin
            test_value = val;
            #10; // Esperar a que se propague
            
            $display("Valor: %d (0x%02h, 0b%08b)", val, val, val);
            $display("  BCD: %03d (0x%03h)", bcd_out, bcd_out);
            $display("  Negativo: %b", negative);
            $display("  SEG3: %07b, SEG2: %07b, SEG1: %07b, SEG0: %07b", 
                     seg3, seg2, seg1, seg0);
            
            // Interpretación decimal
            if (negative) begin
                $display("  Display: -%01d%01d%01d", 
                         bcd_out[11:8], bcd_out[7:4], bcd_out[3:0]);
            end else begin
                $display("  Display: %01d%01d%01d", 
                         bcd_out[11:8], bcd_out[7:4], bcd_out[3:0]);
            end
            $display("  ----");
        end
    endtask

endmodule
