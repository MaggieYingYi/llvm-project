#include <clc/internal/clc.h>

#undef __CLC_FUNCTION
#define __CLC_FUNCTION __clc_rint
#define __CLC_BUILTIN __builtin_elementwise_rint
#include <clc/math/unary_builtin.inc>
