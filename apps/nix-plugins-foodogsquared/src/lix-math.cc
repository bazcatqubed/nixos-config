// SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
//
// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cmath>
#include <lix/libexpr/primops.hh>
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
}
