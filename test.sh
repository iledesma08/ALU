#!/bin/bash

# ========= Tool Check =========
for tool in iverilog vvp; do
    if ! command -v "$tool" &> /dev/null; then
        echo "❌ Error: $tool is not installed. Please install it and re-run this script."
        exit 1
    fi
done

# ========= File Paths =========
SRC_DIR="src"
SIM_DIR="test"
WAVES_DIR="waves"

declare -A modules=(
    ["TOP"]="top"
)

mkdir -p "$WAVES_DIR"

# ========= Module Selection =========
echo "🔍 Choose a module to simulate:"
select opt in "${!modules[@]}" "Quit"; do
    if [[ "$opt" == "Quit" ]]; then
        echo "Exiting."
        exit 0
    elif [[ -n "${modules[$opt]}" ]]; then
        module="${modules[$opt]}"
        break
    else
        echo "❗ Invalid option. Try again."
    fi
done

# ========= File Configuration =========
TB_FILE="$SIM_DIR/test_${module}.v"
OUT_FILE="$SIM_DIR/${module}.out"
VCD_FILE="$WAVES_DIR/${module}.vcd"

# Different source files depending on module
case $module in
    "top")
        SRC_FILES="$SRC_DIR/base_reg.v $SRC_DIR/alu.v $SRC_DIR/top.v"
        ;;
    *)
        echo "❌ Unknown module: $module"
        exit 1
        ;;
esac

# ========= Check Files Exist =========
if [ ! -f "$TB_FILE" ]; then
    echo "❌ Testbench file not found: $TB_FILE"
    exit 1
fi

for src_file in $SRC_FILES; do
    if [ ! -f "$src_file" ]; then
        echo "❌ Source file not found: $src_file"
        exit 1
    fi
done

# ========= Compile =========
echo "🔧 Compiling $module..."
echo "   Sources: $SRC_FILES"
echo "   Testbench: $TB_FILE"

iverilog -o "$OUT_FILE" $SRC_FILES "$TB_FILE"

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed for $module."
    exit 1
fi

echo "✅ Compilation successful!"

# ========= Simulate =========
echo "🚀 Running simulation..."
vvp "$OUT_FILE"

if [ $? -ne 0 ]; then
    echo "❌ Simulation failed for $module."
    exit 1
fi

# ========= Open GTKWave (if VCD exists) =========
if [ -f "$VCD_FILE" ]; then
    echo "📈 VCD file found: $VCD_FILE"
    if command -v gtkwave &> /dev/null; then
        echo "Opening GTKWave..."
        gtkwave "$VCD_FILE" &
    else
        echo "⚠ GTKWave not installed. VCD file saved at: $VCD_FILE"
    fi
else
    echo "ℹ No VCD file generated (normal for monitor-only tests)"
fi

# ========= Cleanup =========
echo "🧹 Cleaning up generated files..."
rm -f "$OUT_FILE"

echo "✅ Done."