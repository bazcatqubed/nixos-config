// SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
//
// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cmath>
#include <lix/libexpr/primops.hh>
#include <lix/libexpr/value.hh>
#include <math.h>
#include <stdlib.h>

static nix::Value prim_fds_math_abs(nix::EvalState &state, nix::Value **args, nix::Value &v) {
    state.forceValue(*args[0], nix::noPos);

    if (args[0]->type() == nix::nFloat) {
        return {
            nix::NewValueAs::floating,
            fabs(
                state.forceFloat(*args[0], nix::noPos, "while getting absolute value")
            ),
        };
    } else {
        return {
            nix::NewValueAs::integer,
            abs(
                state.forceInt(*args[0], nix::noPos, "while getting absolute value").value
            )
        };
    }
}

static nix::Value prim_fds_math_mod(nix::EvalState &state, nix::Value **args, nix::Value &v) {
    state.forceValue(*args[0], nix::noPos);
    state.forceValue(*args[1], nix::noPos);

    if (args[0]->type() == nix::nFloat || args[1]->type() == nix::nFloat) {
        return {
            nix::NewValueAs::floating,
            fmod(
                state.forceFloat(*args[0], nix::noPos, "while evaluating the first operand of the modulo operation"),
                state.forceFloat(*args[1], nix::noPos, "while evaluating the second operand of the modulo operation")
            ),
        };
    } else {
        auto x = state.forceInt(*args[0], nix::noPos, "while evaluating the first operand of the modulo operation");
        auto y = state.forceInt(*args[1], nix::noPos, "while evaluating the second operand of the modulo operation");

        return {
            nix::NewValueAs::integer,
            x.value % y.value
        };
    }
}

static nix::Value prim_fds_math_log(
    nix::EvalState &state, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], nix::noPos);

    return {
        nix::NewValueAs::floating,
        log(
            state.forceFloat(*args[0], nix::noPos, "while evaluating the logarithm")
        )
    };
}

static nix::Value prim_fds_math_log10(
    nix::EvalState &state, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], nix::noPos);
    return {
        nix::NewValueAs::floating,
        log10(
            state.forceFloat(*args[0], nix::noPos, "while evaluating the log10")
        )
    };
}

static nix::Value prim_fds_math_log2(
    nix::EvalState &state, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], nix::noPos);
    return {
        nix::NewValueAs::floating,
        log2(
            state.forceFloat(*args[0], nix::noPos, "while evaluating the log2")
        )
    };
}

static nix::Value prim_fds_math_logx(
    nix::EvalState &state, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], nix::noPos);
    state.forceValue(*args[1], nix::noPos);

    auto b = state.forceFloat(*args[0], nix::noPos, "while evaluating the logx");
    auto x = state.forceFloat(*args[1], nix::noPos, "while evaluating the logx");
    return {
        nix::NewValueAs::floating,
        log(x) / log(b)
    };
}

static nix::Value prim_fds_math_sqrt(
    nix::EvalState &state, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], nix::noPos);

    if (args[0]->type() == nix::nFloat) {
        return {
            nix::NewValueAs::floating,
            sqrt(
                state.forceFloat(*args[0], nix::noPos, "while evaluating the square root")
            )
        };
    } else {
        // FIXME: Check for integer overflow
        auto x = state.forceInt(*args[0], nix::noPos, "while evaluating the square root");
        return {
            nix::NewValueAs::integer,
            sqrtl(x.value)
        };
    }
}

static nix::Value prim_fds_math_cbrt(
    nix::EvalState &state, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], nix::noPos);

    if (args[0]->type() == nix::nFloat) {
        return {
            nix::NewValueAs::floating,
            cbrt(
                state.forceFloat(*args[0], nix::noPos, "while evaluating the cube root")
            )
        };
    } else {
        auto x = state.forceInt(*args[0], nix::noPos, "while evaluating the cube root");
        return {
            nix::NewValueAs::integer,
            cbrtl(x.value)
        };
    }
}

extern "C" void nix_plugin_entry() {
    nix::PluginPrimOps::add({
        .name = "fdsabs",
        .args = { "X" },
        .doc = R"(
            Return the absolute value of `X`.
        )",
        .fun = prim_fds_math_abs,
    });

    nix::PluginPrimOps::add({
        .name = "fdsmod",
        .args = { "X", "Y" },
        .doc = R"(
            Return the value of `X` modulo `Y`.
        )",
        .fun = prim_fds_math_mod,
    });

    nix::PluginPrimOps::add({
        .name = "__log",
        .args = { "X" },
        .doc = R"(
            Return the value of natural logarithm of `X`.
        )",
        .fun = prim_fds_math_log,
    });

    nix::PluginPrimOps::add({
        .name = "__log2",
        .args = { "X" },
        .doc = R"(
            Return the value of base-2 logarithm of `X`.
        )",
        .fun = prim_fds_math_log2,
    });

    nix::PluginPrimOps::add({
        .name = "__log10",
        .args = { "X" },
        .doc = R"(
            Return the value of base-10 logarithm of `X`.
        )",
        .fun = prim_fds_math_log10,
    });

    nix::PluginPrimOps::add({
        .name = "__logx",
        .args = { "BASE", "X" },
        .doc = R"(
            Return the value of given base (`BASE`) logarithm of `X`.
        )",
        .fun = prim_fds_math_logx,
    });

    nix::PluginPrimOps::add({
        .name = "__sqrt",
        .args = { "X" },
        .doc = R"(
            Return the square root of `X`.
        )",
        .fun = prim_fds_math_sqrt,
    });

    nix::PluginPrimOps::add({
        .name = "__cbrt",
        .args = { "X" },
        .doc = R"(
            Return the cube root of `X`.
        )",
        .fun = prim_fds_math_cbrt,
    });
}
