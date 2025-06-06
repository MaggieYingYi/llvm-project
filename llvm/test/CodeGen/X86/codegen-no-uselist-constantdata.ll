; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc -mtriple=x86_64-unknown-linux-gnu < %s | FileCheck %s

; Make sure codegen doesn't try to inspect the use list of constants

; Make sure we do not try to make use of the uselist of a constant
; null when looking for the alignment of the pointer.
define <2 x i32> @no_uselist_null_isDereferenceableAndAlignedPointer(i1 %arg0, ptr align(4) %arg) {
; CHECK-LABEL: no_uselist_null_isDereferenceableAndAlignedPointer:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    cmoveq %rsi, %rax
; CHECK-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    retq
  %select.ptr = select i1 %arg0, ptr null, ptr %arg
  %load = load i32, ptr %select.ptr
  %insert = insertelement <2 x i32> zeroinitializer, i32 %load, i64 0
  ret <2 x i32> %insert
}

; Make sure we do not try to inspect the uselist of a constant null
; when processing a memcpy
define void @gep_nullptr_no_inspect_uselist(ptr %arg) {
; CHECK-LABEL: gep_nullptr_no_inspect_uselist:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movzbl 16, %eax
; CHECK-NEXT:    movb %al, (%rdi)
; CHECK-NEXT:    retq
  %null_gep = getelementptr i8, ptr null, i64 16
  call void @llvm.memcpy.p0.p0.i64(ptr %arg, ptr %null_gep, i64 1, i1 false)
  ret void
}

define <16 x i8> @load_null_offset() {
; CHECK-LABEL: load_null_offset:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movzbl 11, %eax
; CHECK-NEXT:    movd %eax, %xmm0
; CHECK-NEXT:    pslld $8, %xmm0
; CHECK-NEXT:    retq
  %gep.null = getelementptr i8, ptr null, i64 11
  %load = load i8, ptr %gep.null, align 1
  %insert = insertelement <16 x i8> zeroinitializer, i8 %load, i64 1
  ret <16 x i8> %insert
}

declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #0

attributes #0 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
