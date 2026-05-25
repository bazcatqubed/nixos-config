// SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
//
// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cmath>
#include <nix/expr/primops.hh>
#include <stdlib.h>
#include <math.h>

static void prim_fds_math_abs(
    nix::EvalState &state, const nix::PosIdx pos, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], pos);

    if (args[0]->type() == nix::nFloat) {
        v.mkFloat(
            fabs(
                state.forceFloat(*args[0], pos, "while getting absolute value")
            )
        );
    } else {
        v.mkInt(
            abs(
                state.forceInt(*args[0], pos, "while getting absolute value").value
            )
        );
    }
}

static nix::RegisterPrimOp primop_fds_math_abs({
    .name = "__abs",
    .args = { "VAL" },
    .doc = R"(
        Returns the absolute value of a given number.
    )",
    .impl = prim_fds_math_abs,
});

static void prim_fds_math_pow(
    nix::EvalState &state, const nix::PosIdx pos, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], pos);
    state.forceValue(*args[1], pos);
    if (args[0]->type() == nix::nFloat || args[1]->type() == nix::nFloat) {
        v.mkFloat(
            powf(
                state.forceFloat(*args[0], pos, "while evaluating the first argument of the exponentiation"),
                state.forceFloat(*args[1], pos, "while evaluating the second argument of the exponentiation")
            )
        );
    } else {
        auto x = state.forceInt(*args[0], pos, "while evaluating the first argument of the exponentiation");
        auto y = state.forceInt(*args[1], pos, "while evaluating the second argument of the exponentiation");

        v.mkInt(pow(x.value, y.value));
    }
}

static nix::RegisterPrimOp primop_fds_math_pow({
    .name = "__pow",
    .args = { "X", "Y" },
    .doc = R"(
        Returns the value of `X` raised to the power of `Y`.
    )",
    .impl = prim_fds_math_pow
});

static void prim_fds_math_log(
    nix::EvalState &state, const nix::PosIdx pos, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], pos);
    v.mkFloat(
        log(
            state.forceFloat(*args[0], pos, "while evaluating the logarithm")
        )
    );
}

static nix::RegisterPrimOp primop_fds_math_log({
    .name = "__log",
    .args = { "X" },
    .doc = R"(
        Return the value of natural logarithm of `X`.
    )",
    .impl = prim_fds_math_log,
});

static void prim_fds_math_log10(
    nix::EvalState &state, const nix::PosIdx pos, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], pos);
    v.mkFloat(
        log10(
            state.forceFloat(*args[0], pos, "while evaluating the log10")
        )
    );
}

static nix::RegisterPrimOp primop_fds_math_log10({
    .name = "__log10",
    .args = { "X" },
    .doc = R"(
        Return the value of base-10 logarithm of `X`.
    )",
    .impl = prim_fds_math_log10,
});

static void prim_fds_math_log2(
    nix::EvalState &state, const nix::PosIdx pos, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], pos);
    v.mkFloat(
        log2(
            state.forceFloat(*args[0], pos, "while evaluating the log2")
        )
    );
}

static nix::RegisterPrimOp primop_fds_math_log2({
    .name = "__log2",
    .args = { "X" },
    .doc = R"(
        Return the value of base-2 logarithm of `X`.
    )",
    .impl = prim_fds_math_log2,
});

static void prim_fds_math_logx(
    nix::EvalState &state, const nix::PosIdx pos, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], pos);
    state.forceValue(*args[1], pos);

    auto b = state.forceFloat(*args[0], pos, "while evaluating the logx");
    auto x = state.forceFloat(*args[1], pos, "while evaluating the logx");
    v.mkFloat(
        log(x) / log(b)
    );
}

static nix::RegisterPrimOp primop_fds_math_logx({
    .name = "__logx",
    .args = { "BASE", "X" },
    .doc = R"(
        Return the value of given base (`BASE`) logarithm of `X`.
    )",
    .impl = prim_fds_math_logx,
});

static void prim_fds_math_mod(
    nix::EvalState &state, const nix::PosIdx pos, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], pos);
    state.forceValue(*args[1], pos);

    if (args[0]->type() == nix::nFloat || args[1]->type() == nix::nFloat) {
        auto x = state.forceFloat(*args[0], pos, "while evaluating the first argument of the modulo operation");
        auto y = state.forceFloat(*args[1], pos, "while evaluating the second argument of the modulo operation");

        v.mkFloat(fmod(x, y));
    } else {
        auto x = state.forceInt(*args[0], pos, "while evaluating the first argument of the modulo operation");
        auto y = state.forceInt(*args[1], pos, "while evaluating the second argument of the modulo operation");

        v.mkInt(x.value % y.value);
    }
}

static nix::RegisterPrimOp primop_fds_math_mod({
    .name = "__mod",
    .args = { "X", "Y" },
    .doc = R"(
        Returns the value of `X` modulo `Y`.
    )",
    .impl = prim_fds_math_mod,
});

static void prim_fds_math_sqrt(
    nix::EvalState &state, const nix::PosIdx pos, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], pos);

    if (args[0]->type() == nix::nFloat) {
        v.mkFloat(
            sqrt(
                state.forceFloat(*args[0], pos, "while evaluating the square root")
            )
        );
    } else {
        // FIXME: Check for integer overflow
        auto x = state.forceInt(*args[0], pos, "while evaluating the square root");
        v.mkInt(sqrtl(x.value));
    }
}

static nix::RegisterPrimOp primop_fds_math_sqrt({
    .name = "__sqrt",
    .args = { "X" },
    .doc = R"(
        Returns the square root of `X`.
    )",
    .impl = prim_fds_math_sqrt,
});

static void prim_fds_math_cbrt(
    nix::EvalState &state, const nix::PosIdx pos, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], pos);

    if (args[0]->type() == nix::nFloat) {
        v.mkFloat(
            cbrt(
                state.forceFloat(*args[0], pos, "while evaluating the cube root")
            )
        );
    } else {
        auto x = state.forceInt(*args[0], pos, "while evaluating the cube root");
        v.mkInt(cbrtl(x.value));
    }
}

static nix::RegisterPrimOp primop_fds_math_cbrt({
    .name = "__cbrt",
    .args = { "X" },
    .doc = R"(
        Returns the cube root of `X`.
    )",
    .impl = prim_fds_math_cbrt,
});
