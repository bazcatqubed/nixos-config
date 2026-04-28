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
