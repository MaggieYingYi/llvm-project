; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

declare void @use(<4 x i16>)

define void @test(<16 x i8> %w, ptr %o1, ptr %o2) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[V_BC:%.*]] = bitcast <16 x i8> [[W:%.*]] to <4 x i32>
; CHECK-NEXT:    [[V_EXTRACT:%.*]] = extractelement <4 x i32> [[V_BC]], i64 3
; CHECK-NEXT:    [[V_BC1:%.*]] = bitcast <16 x i8> [[W]] to <4 x float>
; CHECK-NEXT:    [[V_EXTRACT2:%.*]] = extractelement <4 x float> [[V_BC1]], i64 3
; CHECK-NEXT:    store i32 [[V_EXTRACT]], ptr [[O1:%.*]], align 4
; CHECK-NEXT:    store float [[V_EXTRACT2]], ptr [[O2:%.*]], align 4
; CHECK-NEXT:    ret void
;
  %v = shufflevector <16 x i8> %w, <16 x i8> undef, <4 x i32> <i32 12, i32 13, i32 14, i32 15>
  %f = bitcast <4 x i8> %v to float
  %i = bitcast <4 x i8> %v to i32
  store i32 %i, ptr %o1, align 4
  store float %f, ptr %o2, align 4
  ret void
}

; Shuffle-of-bitcast-splat --> splat-bitcast

define <4 x i16> @splat_bitcast_operand(<8 x i8> %x) {
; CHECK-LABEL: @splat_bitcast_operand(
; CHECK-NEXT:    [[S1:%.*]] = shufflevector <8 x i8> [[X:%.*]], <8 x i8> poison, <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
; CHECK-NEXT:    [[S2:%.*]] = bitcast <8 x i8> [[S1]] to <4 x i16>
; CHECK-NEXT:    ret <4 x i16> [[S2]]
;
  %s1 = shufflevector <8 x i8> %x, <8 x i8> undef, <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %bc = bitcast <8 x i8> %s1 to <4 x i16>
  %s2 = shufflevector <4 x i16> %bc, <4 x i16> undef, <4 x i32> <i32 0, i32 2, i32 1, i32 0>
  ret <4 x i16> %s2
}

; Shuffle-of-bitcast-splat --> splat-bitcast

define <4 x i16> @splat_bitcast_operand_uses(<8 x i8> %x) {
; CHECK-LABEL: @splat_bitcast_operand_uses(
; CHECK-NEXT:    [[S1:%.*]] = shufflevector <8 x i8> [[X:%.*]], <8 x i8> poison, <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
; CHECK-NEXT:    [[BC:%.*]] = bitcast <8 x i8> [[S1]] to <4 x i16>
; CHECK-NEXT:    call void @use(<4 x i16> [[BC]])
; CHECK-NEXT:    [[S2:%.*]] = bitcast <8 x i8> [[S1]] to <4 x i16>
; CHECK-NEXT:    ret <4 x i16> [[S2]]
;
  %s1 = shufflevector <8 x i8> %x, <8 x i8> undef, <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %bc = bitcast <8 x i8> %s1 to <4 x i16>
  call void @use(<4 x i16> %bc)
  %s2 = shufflevector <4 x i16> %bc, <4 x i16> undef, <4 x i32> <i32 0, i32 2, i32 1, i32 0>
  ret <4 x i16> %s2
}

; Shuffle-of-bitcast-splat --> splat-bitcast

define <4 x i32> @splat_bitcast_operand_same_size_src_elt(<4 x float> %x) {
; CHECK-LABEL: @splat_bitcast_operand_same_size_src_elt(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast <4 x float> [[X:%.*]] to <4 x i32>
; CHECK-NEXT:    [[BC:%.*]] = shufflevector <4 x i32> [[TMP1]], <4 x i32> poison, <4 x i32> <i32 2, i32 2, i32 2, i32 2>
; CHECK-NEXT:    ret <4 x i32> [[BC]]
;
  %s1 = shufflevector <4 x float> %x, <4 x float> undef, <4 x i32> <i32 2, i32 2, i32 2, i32 2>
  %bc = bitcast <4 x float> %s1 to <4 x i32>
  %s2 = shufflevector <4 x i32> %bc, <4 x i32> undef, <4 x i32> <i32 0, i32 2, i32 1, i32 0>
  ret <4 x i32> %s2
}

; Scaled mask is inverse of first mask.

define <4 x i32> @shuf_bitcast_operand(<16 x i8> %x) {
; CHECK-LABEL: @shuf_bitcast_operand(
; CHECK-NEXT:    [[S2:%.*]] = bitcast <16 x i8> [[X:%.*]] to <4 x i32>
; CHECK-NEXT:    ret <4 x i32> [[S2]]
;
  %s1 = shufflevector <16 x i8> %x, <16 x i8> undef, <16 x i32> <i32 12, i32 13, i32 14, i32 15, i32 8, i32 9, i32 10, i32 11, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
  %bc = bitcast <16 x i8> %s1 to <4 x i32>
  %s2 = shufflevector <4 x i32> %bc, <4 x i32> undef, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  ret <4 x i32> %s2
}

; TODO: Could allow fold for length-changing shuffles.

define <5 x i16> @splat_bitcast_operand_change_type(<8 x i8> %x) {
; CHECK-LABEL: @splat_bitcast_operand_change_type(
; CHECK-NEXT:    [[S1:%.*]] = shufflevector <8 x i8> [[X:%.*]], <8 x i8> poison, <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
; CHECK-NEXT:    [[BC:%.*]] = bitcast <8 x i8> [[S1]] to <4 x i16>
; CHECK-NEXT:    [[S2:%.*]] = shufflevector <4 x i16> [[BC]], <4 x i16> poison, <5 x i32> <i32 0, i32 2, i32 1, i32 0, i32 3>
; CHECK-NEXT:    ret <5 x i16> [[S2]]
;
  %s1 = shufflevector <8 x i8> %x, <8 x i8> undef, <8 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %bc = bitcast <8 x i8> %s1 to <4 x i16>
  %s2 = shufflevector <4 x i16> %bc, <4 x i16> undef, <5 x i32> <i32 0, i32 2, i32 1, i32 0, i32 3>
  ret <5 x i16> %s2
}

; Shuffle-of-bitcast-splat --> splat-bitcast

define <4 x i16> @splat_bitcast_operand_wider_src_elt(<2 x i32> %x) {
; CHECK-LABEL: @splat_bitcast_operand_wider_src_elt(
; CHECK-NEXT:    [[S1:%.*]] = shufflevector <2 x i32> [[X:%.*]], <2 x i32> poison, <2 x i32> <i32 1, i32 1>
; CHECK-NEXT:    [[S2:%.*]] = bitcast <2 x i32> [[S1]] to <4 x i16>
; CHECK-NEXT:    ret <4 x i16> [[S2]]
;
  %s1 = shufflevector <2 x i32> %x, <2 x i32> undef, <2 x i32> <i32 1, i32 1>
  %bc = bitcast <2 x i32> %s1 to <4 x i16>
  %s2 = shufflevector <4 x i16> %bc, <4 x i16> undef, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  ret <4 x i16> %s2
}

; Shuffle-of-bitcast-splat --> splat-bitcast

define <4 x i16> @splat_bitcast_operand_wider_src_elt_uses(<2 x i32> %x) {
; CHECK-LABEL: @splat_bitcast_operand_wider_src_elt_uses(
; CHECK-NEXT:    [[S1:%.*]] = shufflevector <2 x i32> [[X:%.*]], <2 x i32> poison, <2 x i32> <i32 1, i32 1>
; CHECK-NEXT:    [[BC:%.*]] = bitcast <2 x i32> [[S1]] to <4 x i16>
; CHECK-NEXT:    call void @use(<4 x i16> [[BC]])
; CHECK-NEXT:    [[S2:%.*]] = bitcast <2 x i32> [[S1]] to <4 x i16>
; CHECK-NEXT:    ret <4 x i16> [[S2]]
;
  %s1 = shufflevector <2 x i32> %x, <2 x i32> undef, <2 x i32> <i32 1, i32 1>
  %bc = bitcast <2 x i32> %s1 to <4 x i16>
  call void @use(<4 x i16> %bc)
  %s2 = shufflevector <4 x i16> %bc, <4 x i16> undef, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  ret <4 x i16> %s2
}

; Scaled mask is inverse of first mask.

define <16 x i8> @shuf_bitcast_operand_wider_src(<4 x i32> %x) {
; CHECK-LABEL: @shuf_bitcast_operand_wider_src(
; CHECK-NEXT:    [[S2:%.*]] = bitcast <4 x i32> [[X:%.*]] to <16 x i8>
; CHECK-NEXT:    ret <16 x i8> [[S2]]
;
  %s1 = shufflevector <4 x i32> %x, <4 x i32> undef, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %bc = bitcast <4 x i32> %s1 to <16 x i8>
  %s2 = shufflevector <16 x i8> %bc, <16 x i8> undef, <16 x i32> <i32 12, i32 13, i32 14, i32 15, i32 8, i32 9, i32 10, i32 11, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
  ret <16 x i8> %s2
}

; Negative test - the 2nd mask can't be widened

define <16 x i8> @shuf_bitcast_operand_cannot_widen(<4 x i32> %x) {
; CHECK-LABEL: @shuf_bitcast_operand_cannot_widen(
; CHECK-NEXT:    [[S1:%.*]] = shufflevector <4 x i32> [[X:%.*]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; CHECK-NEXT:    [[BC:%.*]] = bitcast <4 x i32> [[S1]] to <16 x i8>
; CHECK-NEXT:    [[S2:%.*]] = shufflevector <16 x i8> [[BC]], <16 x i8> poison, <16 x i32> <i32 12, i32 13, i32 12, i32 13, i32 8, i32 9, i32 10, i32 11, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    ret <16 x i8> [[S2]]
;
  %s1 = shufflevector <4 x i32> %x, <4 x i32> undef, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %bc = bitcast <4 x i32> %s1 to <16 x i8>
  %s2 = shufflevector <16 x i8> %bc, <16 x i8> undef, <16 x i32> <i32 12, i32 13, i32 12, i32 13, i32 8, i32 9, i32 10, i32 11, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
  ret <16 x i8> %s2
}

; Negative test - the 2nd mask can't be widened

define <16 x i8> @shuf_bitcast_operand_cannot_widen_undef(<4 x i32> %x) {
; CHECK-LABEL: @shuf_bitcast_operand_cannot_widen_undef(
; CHECK-NEXT:    [[S1:%.*]] = shufflevector <4 x i32> [[X:%.*]], <4 x i32> poison, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; CHECK-NEXT:    [[BC:%.*]] = bitcast <4 x i32> [[S1]] to <16 x i8>
; CHECK-NEXT:    [[S2:%.*]] = shufflevector <16 x i8> [[BC]], <16 x i8> poison, <16 x i32> <i32 12, i32 poison, i32 14, i32 15, i32 8, i32 9, i32 10, i32 11, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    ret <16 x i8> [[S2]]
;
  %s1 = shufflevector <4 x i32> %x, <4 x i32> undef, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %bc = bitcast <4 x i32> %s1 to <16 x i8>
  %s2 = shufflevector <16 x i8> %bc, <16 x i8> undef, <16 x i32> <i32 12, i32 undef, i32 14, i32 15, i32 8, i32 9, i32 10, i32 11, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3>
  ret <16 x i8> %s2
}

define <2 x i4> @shuf_bitcast_insert(<2 x i8> %v, i8 %x) {
; CHECK-LABEL: @shuf_bitcast_insert(
; CHECK-NEXT:    [[R:%.*]] = bitcast i8 [[X:%.*]] to <2 x i4>
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %i = insertelement <2 x i8> %v, i8 %x, i32 0
  %b = bitcast <2 x i8> %i to <4 x i4>
  %r = shufflevector <4 x i4> %b, <4 x i4> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x i4> %r
}

define <2 x i4> @shuf_bitcast_inserti_use1(<2 x i8> %v, i8 %x, ptr %p) {
; CHECK-LABEL: @shuf_bitcast_inserti_use1(
; CHECK-NEXT:    [[I:%.*]] = insertelement <2 x i8> [[V:%.*]], i8 [[X:%.*]], i64 0
; CHECK-NEXT:    store <2 x i8> [[I]], ptr [[P:%.*]], align 2
; CHECK-NEXT:    [[R:%.*]] = bitcast i8 [[X]] to <2 x i4>
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %i = insertelement <2 x i8> %v, i8 %x, i32 0
  store <2 x i8> %i, ptr %p
  %b = bitcast <2 x i8> %i to <4 x i4>
  %r = shufflevector <4 x i4> %b, <4 x i4> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x i4> %r
}

define <2 x i4> @shuf_bitcast_insert_use2(<2 x i8> %v, i8 %x, ptr %p) {
; CHECK-LABEL: @shuf_bitcast_insert_use2(
; CHECK-NEXT:    [[I:%.*]] = insertelement <2 x i8> [[V:%.*]], i8 [[X:%.*]], i64 0
; CHECK-NEXT:    store <2 x i8> [[I]], ptr [[P:%.*]], align 2
; CHECK-NEXT:    [[R:%.*]] = bitcast i8 [[X]] to <2 x i4>
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %i = insertelement <2 x i8> %v, i8 %x, i32 0
  %b = bitcast <2 x i8> %i to <4 x i4>
  store <4 x i4> %b, ptr %p
  %r = shufflevector <4 x i4> %b, <4 x i4> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x i4> %r
}

; negative test - but demanded elements reduces this.

define <2 x i4> @shuf_bitcast_insert_wrong_index(<2 x i8> %v, i8 %x) {
; CHECK-LABEL: @shuf_bitcast_insert_wrong_index(
; CHECK-NEXT:    [[B:%.*]] = bitcast <2 x i8> [[V:%.*]] to <4 x i4>
; CHECK-NEXT:    [[R:%.*]] = shufflevector <4 x i4> [[B]], <4 x i4> poison, <2 x i32> <i32 0, i32 1>
; CHECK-NEXT:    ret <2 x i4> [[R]]
;
  %i = insertelement <2 x i8> %v, i8 %x, i32 1
  %b = bitcast <2 x i8> %i to <4 x i4>
  %r = shufflevector <4 x i4> %b, <4 x i4> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x i4> %r
}

; negative test

define <3 x i4> @shuf_bitcast_wrong_size(<2 x i8> %v, i8 %x) {
; CHECK-LABEL: @shuf_bitcast_wrong_size(
; CHECK-NEXT:    [[I:%.*]] = insertelement <2 x i8> [[V:%.*]], i8 [[X:%.*]], i64 0
; CHECK-NEXT:    [[B:%.*]] = bitcast <2 x i8> [[I]] to <4 x i4>
; CHECK-NEXT:    [[R:%.*]] = shufflevector <4 x i4> [[B]], <4 x i4> poison, <3 x i32> <i32 0, i32 1, i32 2>
; CHECK-NEXT:    ret <3 x i4> [[R]]
;
  %i = insertelement <2 x i8> %v, i8 %x, i32 0
  %b = bitcast <2 x i8> %i to <4 x i4>
  %r = shufflevector <4 x i4> %b, <4 x i4> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x i4> %r
}

; Negative test - chain of bitcasts.

define <16 x i8> @shuf_bitcast_chain(<8 x i32> %v) {
; CHECK-LABEL: @shuf_bitcast_chain(
; CHECK-NEXT:    [[S:%.*]] = shufflevector <8 x i32> [[V:%.*]], <8 x i32> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    [[C:%.*]] = bitcast <4 x i32> [[S]] to <16 x i8>
; CHECK-NEXT:    ret <16 x i8> [[C]]
;
  %s = shufflevector <8 x i32> %v, <8 x i32> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %a = bitcast <4 x i32> %s to <2 x i64>
  %b = bitcast <2 x i64> %a to i128
  %c = bitcast i128 %b to <16 x i8>
  ret <16 x i8> %c
}

; Same as above, but showing why it's not feasable to implement the reverse
; fold in VectorCombine (see #136998).

define <4 x i32> @shuf_bitcast_chain_2(<8 x i32> %v) {
; CHECK-LABEL: @shuf_bitcast_chain_2(
; CHECK-NEXT:    [[S0:%.*]] = shufflevector <8 x i32> [[V:%.*]], <8 x i32> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    [[S1:%.*]] = shufflevector <8 x i32> [[V]], <8 x i32> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
; CHECK-NEXT:    [[R:%.*]] = or <4 x i32> [[S0]], [[S1]]
; CHECK-NEXT:    ret <4 x i32> [[R]]
;
  %s0 = shufflevector <8 x i32> %v, <8 x i32> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %s1 = shufflevector <8 x i32> %v, <8 x i32> poison, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %b0 = bitcast <4 x i32> %s0 to i128
  %b1 = bitcast <4 x i32> %s1 to i128
  %c0 = bitcast i128 %b0 to <4 x i32>
  %c1 = bitcast i128 %b1 to <4 x i32>
  %r = or <4 x i32> %c0, %c1
  ret <4 x i32> %r
}
