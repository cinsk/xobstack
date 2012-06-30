Xobstack
========

eXtended GNU obstack

Xobstack is almost identical to the GNU obstack, except few things:

* provides better error handling; all allocation function will return error codes.
* thread safe; since it does not have global failure handling function (as in obstack, `obstack_alloc_failed_handler`.
* debugging support -- by defining DEBUG macro before compiling, you can verify your code with the help of external tools (such as valgrind, efence, duma.)
* different supported platform -- Xobstack supports GNU C or other C compilers that support inline functions.  Unlike obstack, old C compilers are not supported.

Interface
---------

All macros and functions are prefixed with `xobs_` instead of `obstack_`.

If the function may need to call the allocation function, the corresponding
`xobs_` function may return the error status:
* If the function returns a pointer to the allocated memory, it will return NULL if the allocation failed. (e.g. `xobs_alloc`, `xobs_copy`, `xobs_copy0`, `xobs_finished`, etc.)
* If the function does not return a pointer, it will return 1 on success.  On error, it will return 0. (e.g. `xobs_init`, `xobs_begin`, or growing functions like `xobs_blank`, `xobs_grow`, `xobs_ptr_grow`, etc.)

Except the return value, all `xobs_` functions behave the same as
`obstack_` functions.


Debugging
---------

Debugging a code that uses GNU obstack is painful.  Since the memory is managed
by obstack in chunks, external tools such as [valgrind](http://valgrind.org/), [Electric Fence](http://perens.com/FreeSoftware/ElectricFence), or [DUMA](http://duma.sourceforge.net/) cannot help you.

Xobstack helps in this case, if you define `DEBUG` macro on compilation. If `DEBUG` is defined, Xobstack simulates GNU obstack interface using pure malloc/free per each object allocation.  In this way, you can easily verify your code with above external tools.
