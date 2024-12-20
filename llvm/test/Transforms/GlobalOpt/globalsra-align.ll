; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --check-globals
; RUN: opt < %s -passes=globalopt -S | FileCheck %s

target datalayout = "p:16:32:64" ; 16-bit pointers with 32-bit ABI alignment and 64-bit preferred alignmentt

@a = internal externally_initialized global [3 x [7 x ptr]] zeroinitializer, align 16

; PR50253
; The alignments are correct initially, but they should be updated
; after transforming the global. The stored global pointer array retains
; its original "align 16", so access to element N into the new array
; should be offset by the ABI alignment of N pointers.
; Loaded globals are split into individual pointers and use the
; preferred alignment from the datalayout.

;.
; CHECK: @[[A_4:[a-zA-Z0-9_$"\\.-]+]] = internal unnamed_addr externally_initialized global ptr null, align 8
; CHECK: @[[A_5:[a-zA-Z0-9_$"\\.-]+]] = internal unnamed_addr externally_initialized global ptr null, align 8
; CHECK: @[[A_6:[a-zA-Z0-9_$"\\.-]+]] = internal unnamed_addr externally_initialized global ptr null, align 16
; CHECK: @[[A_7:[a-zA-Z0-9_$"\\.-]+]] = internal unnamed_addr externally_initialized global ptr null, align 8
;.
define ptr @reduce_align_0() {
; CHECK-LABEL: @reduce_align_0(
; CHECK-NEXT:    [[X:%.*]] = load ptr, ptr @a.4, align 8
; CHECK-NEXT:    ret ptr [[X]]
;
  %x = load ptr, ptr getelementptr inbounds ([3 x [7 x ptr]], ptr @a, i64 0, i64 2, i64 0), align 8
  store ptr null, ptr getelementptr inbounds ([3 x [7 x ptr]], ptr @a, i64 0, i64 1, i64 0), align 4
  ret ptr %x
}

define ptr @reduce_align_1() {
; CHECK-LABEL: @reduce_align_1(
; CHECK-NEXT:    [[X:%.*]] = load ptr, ptr @a.5, align 8
; CHECK-NEXT:    ret ptr [[X]]
;
  %x = load ptr, ptr getelementptr inbounds ([3 x [7 x ptr]], ptr @a, i64 0, i64 2, i64 1), align 4
  store ptr null, ptr getelementptr inbounds ([3 x [7 x ptr]], ptr @a, i64 0, i64 1, i64 1), align 16
  ret ptr %x
}

define ptr @reduce_align_2() {
; CHECK-LABEL: @reduce_align_2(
; CHECK-NEXT:    [[X:%.*]] = load ptr, ptr @a.6, align 16
; CHECK-NEXT:    ret ptr [[X]]
;
  %x = load ptr, ptr getelementptr inbounds ([3 x [7 x ptr]], ptr @a, i64 0, i64 2, i64 2), align 16
  store ptr null, ptr getelementptr inbounds ([3 x [7 x ptr]], ptr @a, i64 0, i64 1, i64 2), align 4
  ret ptr %x
}

define ptr @reduce_align_3() {
; CHECK-LABEL: @reduce_align_3(
; CHECK-NEXT:    [[X:%.*]] = load ptr, ptr @a.7, align 8
; CHECK-NEXT:    ret ptr [[X]]
;
  %x = load ptr, ptr getelementptr inbounds ([3 x [7 x ptr]], ptr @a, i64 0, i64 2, i64 3), align 4
  store ptr null, ptr getelementptr inbounds ([3 x [7 x ptr]], ptr @a, i64 0, i64 1, i64 3), align 8
  ret ptr %x
}
