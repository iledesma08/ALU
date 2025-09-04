#!/bin/bash

# Script para simular ALU con displays de 7 segmentos
# Uso: ./test_7seg.sh

echo "=== Simulación ALU con Displays de 7 Segmentos ==="

# Crear directorio para resultados si no existe
mkdir -p waves

# Compilar y simular con iverilog
echo "Compilando..."
iverilog -o waves/test_top_7seg \
    src/alu.v \
    src/base_reg.v \
    src/bin_to_bcd.v \
    src/bcd_to_7seg.v \
    src/display_mux.v \
    src/top.v \
    test/test_top_7seg.v

# Verificar si la compilación fue exitosa
if [ $? -eq 0 ]; then
    echo "Compilación exitosa"
    echo "Ejecutando simulación..."
    
    # Ejecutar simulación
    cd waves
    ./test_top_7seg
    
    # Verificar si se generó el archivo VCD
    if [ -f "test_top_7seg.vcd" ]; then
        echo "Simulación completada"
        echo "Archivo de ondas generado: waves/test_top_7seg.vcd"
        echo "Para ver las ondas, usa: gtkwave waves/test_top_7seg.vcd"
    else
        echo "Error: No se generó el archivo de ondas"
    fi
else
    echo "Error en la compilación"
    exit 1
fi

echo "=== Fin de la simulación ==="
