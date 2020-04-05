#if DM_VERSION < 513
#define ismovableatom(A) (istype(A, /atom/movable))
#else
#define ismovableatom(A) ismovable(A)