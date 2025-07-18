# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=riscv64 -mcpu=sifive-x280 -iterations=1 < %s | FileCheck %s

# TODO: This test should be replaced by an exhaustive test of legal (LMUL, SEW)
# pairs for all instructions in the Vector Integer Arithmetic chapter of the RVV
# SPEC.
vsetvli zero, zero, e32, mf2, tu, mu
vdiv.vv v12, v12, v12
vsetvli zero, zero, e8, mf8, tu, mu
vdiv.vv v12, v12, v12

# CHECK:      Iterations:        1
# CHECK-NEXT: Instructions:      4
# CHECK-NEXT: Total Cycles:      91
# CHECK-NEXT: Total uOps:        4

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    0.04
# CHECK-NEXT: IPC:               0.04
# CHECK-NEXT: Block RThroughput: 88.0

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                  U     vsetvli	zero, zero, e32, mf2, tu, mu
# CHECK-NEXT:  1      56    56.00                       vdiv.vv	v12, v12, v12
# CHECK-NEXT:  1      3     1.00                  U     vsetvli	zero, zero, e8, mf8, tu, mu
# CHECK-NEXT:  1      30    30.00                       vdiv.vv	v12, v12, v12

# CHECK:      Resources:
# CHECK-NEXT: [0]   - VLEN512SiFive7FDiv
# CHECK-NEXT: [1]   - VLEN512SiFive7IDiv
# CHECK-NEXT: [2]   - VLEN512SiFive7PipeA
# CHECK-NEXT: [3]   - VLEN512SiFive7PipeB
# CHECK-NEXT: [4]   - VLEN512SiFive7VA
# CHECK-NEXT: [5]   - VLEN512SiFive7VCQ
# CHECK-NEXT: [6]   - VLEN512SiFive7VL
# CHECK-NEXT: [7]   - VLEN512SiFive7VS

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]
# CHECK-NEXT:  -      -     2.00    -     88.00  2.00    -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    Instructions:
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vsetvli	zero, zero, e32, mf2, tu, mu
# CHECK-NEXT:  -      -      -      -     57.00  1.00    -      -     vdiv.vv	v12, v12, v12
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     vsetvli	zero, zero, e8, mf8, tu, mu
# CHECK-NEXT:  -      -      -      -     31.00  1.00    -      -     vdiv.vv	v12, v12, v12
