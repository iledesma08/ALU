# 🔢 ALU - Arithmetic Logic Unit

## 📋 Descripción

Este proyecto implementa una **ALU (Arithmetic Logic Unit)** completa en Verilog, diseñada como parte del curso de Arquitectura de Computadoras. La ALU es un componente fundamental de cualquier procesador, capaz de realizar operaciones aritméticas y lógicas sobre datos binarios.

### 🎯 Características Principales

- **8 operaciones** implementadas (aritméticas y lógicas)
- **Arquitectura parameterizable** con ancho de datos configurable
- **Registros base** para almacenamiento de operandos
- **Flags de estado** (zero, overflow)
- **Testbench con casos de prueba** utilizando datos aleatorios
- **Script de simulación** automatizado

## 🏗️ Arquitectura del Sistema

El proyecto está estructurado en tres módulos principales:

### 1. 🧮 Módulo ALU (`alu.v`)
- **Entrada**: Dos operandos de N bits + código de operación
- **Salida**: Resultado de N bits + flags de estado
- **Operaciones soportadas**:
  - `ADD` (100000): Suma aritmética
  - `SUB` (100010): Resta aritmética  
  - `AND` (100100): AND lógico bit a bit
  - `OR`  (100101): OR lógico bit a bit
  - `XOR` (100110): XOR lógico bit a bit
  - `NOR` (100111): NOR lógico bit a bit
  - `SRA` (000011): Shift aritmético a la derecha
  - `SRL` (000010): Shift lógico a la derecha

### 2. 📝 Módulo Registro Base (`base_reg.v`)
- **Función**: Almacenamiento temporal de datos
- **Características**: 
  - Enable de escritura independiente
  - Reset asíncrono
  - Ancho parametrizable

### 3. 🔗 Módulo TOP (`top.v`)
- **Función**: Integración completa del sistema
- **Componentes**: 3 registros base (2 operandos y 1 opcode) + 1 ALU
- **Interface**: Control de carga independiente para cada operando y operación

## 🚀 Instalación y Configuración

### Prerrequisitos

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y iverilog gtkwave
```

### Descarga del Proyecto

```bash
# Clonar el repositorio
git clone https://github.com/iledesma08/ALU.git
cd ALU
```

## 🧪 Guía de Uso

### Script de Simulación

```bash
# Ejecutar script de simulación interactivo
./test.sh

# El script preguntará qué módulo probar:
# 1) TOP - Test completo del sistema
# 2) Quit - Salir
```

### Funcionamiento del Script

El script `test.sh` automatiza todo el proceso:

1. **Verificación de herramientas**: Confirma que `iverilog` y `vvp` están instalados
2. **Compilación**: Compila automáticamente los módulos fuente y testbench
3. **Simulación**: Ejecuta la simulación con el testbench
4. **Resultados**: Muestra los resultados en tiempo real
5. **Cleanup**: Limpia archivos temporales automáticamente

## 📊 Casos de Prueba

El testbench automatizado incluye:

- **50 tests aleatorios** con datos generados pseudo-aleatoriamente
- **Sincronización por clock** para timing realista
- **Verificación automática** de resultados esperados vs obtenidos
- **Cobertura completa** de todas las operaciones
- **Validación de flags** (zero, overflow)
- **Reporte detallado** de pass/fail por test

### Ejemplo de Salida de Test

```text
TESTBENCH para módulo TOP - ALU con registros
============================================================
Parámetros: NB_DATA=8, NB_OP=6
Operaciones soportadas: ADD, SUB, AND, OR, XOR, NOR, SRA, SRL

PASS [1] - SUB: A=36, B=129 -> Result=163 (zero=0, overflow=1)
PASS [2] - NOR: A=99, B=13 -> Result=144 (zero=0, overflow=0)
PASS [3] - SUB: A=101, B=18 -> Result=83 (zero=0, overflow=0)
...
Tests ejecutados: 50
Tests pasados: 50
Tests fallidos: 0
Tasa de éxito: 100.0%
✓ TODOS LOS TESTS PASARON!
```

## 📁 Estructura del Proyecto

```text
ALU/
├── 📂 src/                    # Código fuente Verilog
│   ├── alu.v                  # Módulo ALU principal
│   ├── base_reg.v             # Registro base
│   └── top.v                  # Módulo de integración
├── 📂 test/                   # Testing y validación
│   └── test_top.v             # Testbench principal
├── 📄 test.sh                 # Script de simulación automatizado
├── � .gitignore              # Archivos ignorados por Git
├── 📄 LICENSE                 # Licencia del proyecto
└── 📄 README.md               # Esta documentación
```

## 🎛️ Personalización

### Parámetros Configurables

```verilog
// En top.v - Ejemplo de instanciación personalizada
top #(
    .NB_DATA(16),    // Cambiar ancho de datos a 16 bits
    .NB_OP(6)        // Mantener 6 bits para operaciones
) mi_alu (
    // ... conexiones ...
);
```

### Agregar Nuevas Operaciones

1. Definir nuevo código de operación en `alu.v`
2. Implementar lógica en el bloque `always`
3. Actualizar testbench con casos de prueba
4. Ejecutar tests de validación

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor sigue estas pautas:

### 🔄 Proceso de Contribución

1. **Fork** el repositorio
2. **Crea** una rama feature (`git checkout -b feature/nueva-operacion`)
3. **Implementa** tus cambios siguiendo el estilo del código
4. **Ejecuta** los tests localmente (`./test.sh`)
5. **Commit** con mensajes descriptivos (`git commit -m 'Add: nueva operación XYZ'`)
6. **Push** a tu rama (`git push origin feature/nueva-operacion`)
7. **Abre** un Pull Request con descripción detallada

### ✅ Checklist de Contribución

- [ ] Tests pasan localmente (`./test.sh`)
- [ ] Código sigue convenciones de Verilog
- [ ] Documentación actualizada si es necesario
- [ ] Commits tienen mensajes descriptivos
- [ ] Módulos compilan sin errores o warnings

### 📝 Estilo de Código

- **Indentación**: 4 espacios
- **Naming**: `snake_case` para señales, `UPPER_CASE` para parámetros
- **Comentarios**: Documenta bloques complejos y parámetros
- **Modularidad**: Mantén módulos pequeños y cohesivos

## 📄 Licencia

Este proyecto está licenciado bajo la **MIT License**. Ver el archivo [LICENSE](LICENSE) para más detalles.
