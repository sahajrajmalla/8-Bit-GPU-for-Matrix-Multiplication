
# 8-Bit GPU for 2×2 Matrix Multiplication

A minimalist SystemVerilog design that multiplies two 2×2 matrices in parallel using four 8-bit Processing Units (PUs) and a simple FSM controller.

---

## 🔍 Overview

- **Input**: Two 2×2 matrices A and B (8 bits per element).
- **Output**: 2×2 result matrix C (16 bits per element, little-endian).
- **Memory**: 16 bytes (128 bits) to hold A, B and C.
- **Parallelism**: Four identical PUs compute C[0,0], C[0,1], C[1,0], C[1,1] simultaneously.
- **Controller**: Manages compute and store phases in a three-state FSM.

---

## 📂 Repository Structure

```
├── LICENSE
├── README.md
├── circuit_diagram.txt   // ASCII-style top-level diagram
├── design.sv             // GPU_Top, Memory, Controller, PU modules
└── testbench.sv          // tb: drives vectors & displays result
```

---

## 🚀 Quick Simulation

```bash
# Compile & run
iverilog -g2012 design.sv testbench.sv -o gpu_sim
vvp gpu_sim
```

Sample output for A=B=Identity:
```
Test Case 1: A=[1,1;1,1], B=[1,1;1,1]
  C[0,0] = 2
  C[0,1] = 2
  C[1,0] = 2
  C[1,1] = 2
```

---

## 📋 Memory Map

| Addr  | Contents     |
|:-----:|:-------------|
| 0–3   | A[0,0], A[0,1], A[1,0], A[1,1] |
| 4–7   | B[0,0], B[0,1], B[1,0], B[1,1] |
| 8–9   | C[0,0] (LE)  |
| 10–11 | C[0,1] (LE)  |
| 12–13 | C[1,0] (LE)  |
| 14–15 | C[1,1] (LE)  |

---

## 📄 License

This project is released under the **GPL-3.0** License.  
See [LICENSE](./LICENSE) for details.
