#include "conductor.hpp"
#include "audio.hpp"
#include "scope.hpp"
#include "midi.hpp"
#include "dsp.hpp"
#include "external/tinycc/libtcc.h"

void handle_error(void *opaque, const char *msg)
{
    fprintf((FILE*)opaque, "%s\n", msg);
}

char my_program[] =
"int fib(int n)\n"
"{\n"
"    if (n <= 2)\n"
"        return 1;\n"
"    else\n"
"        return fib(n-1) + fib(n-2);\n"
"}\n";

void tcc() {

    TCCState *s;
    int (*func)(int);

    s = tcc_new();
    if (!s) {
        fprintf(stderr, "Could not create tcc state\n");
        exit(1);
    }

    assert(tcc_get_error_func(s) == NULL);
    assert(tcc_get_error_opaque(s) == NULL);

    tcc_set_error_func(s, stderr, handle_error);

    assert(tcc_get_error_func(s) == handle_error);
    assert(tcc_get_error_opaque(s) == stderr);

    tcc_add_include_path(s, ".");

    /* MUST BE CALLED before any compilation */
    tcc_set_output_type(s, TCC_OUTPUT_MEMORY);

    if (tcc_compile_string(s, my_program) == -1)
        return;

    /* relocate the code */
    if (tcc_relocate(s, TCC_RELOCATE_AUTO) < 0)
        return;

    /* get entry symbol */
    func = (int(*)(int)) tcc_get_symbol(s, "fib");
    if (!func)
        return;

    /* run the code */
    int ret = func(32);
    qDebug() << "fib(32) =" << ret;

    /* delete the state */
    tcc_delete(s);
}



int main(int argc, char **argv) {
    tcc();
    qDebug() << sizeof(maestro.ticks);
    return maestro.run(argc, argv);
}
