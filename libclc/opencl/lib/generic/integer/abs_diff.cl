//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <clc/integer/clc_abs_diff.h>
#include <clc/opencl/integer/abs_diff.h>

#define __CLC_BODY <abs_diff.inc>
#include <clc/integer/gentype.inc>
