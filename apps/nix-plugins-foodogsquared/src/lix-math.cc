// SPDX-FileCopyrightText: 2026 Gabriel Arazas <foodogsquared@foodogsquared.one>
//
// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cmath>
#include <functional>
#include <lix/libexpr/primops.hh>
#include <lix/libexpr/value.hh>
#include <math.h>
#include <stdlib.h>

static void prim_fds_math_abs(nix::EvalState &state, nix::Value **args, nix::Value &v) {
    state.forceValue(*args[0], nix::noPos);

    if (args[0]->type() == nix::nFloat) {
        v = {
            nix::NewValueAs::floating,
            fabs(
                state.forceFloat(*args[0], nix::noPos, "while getting absolute value")
            ),
        };
    } else {
        v = {
            nix::NewValueAs::integer,
            abs(
                state.forceInt(*args[0], nix::noPos, "while getting absolute value").value
            )
        };
    }
}

static void prim_fds_math_mod(nix::EvalState &state, nix::Value **args, nix::Value &v) {
    state.forceValue(*args[0], nix::noPos);
    state.forceValue(*args[1], nix::noPos);

    if (args[0]->type() == nix::nFloat || args[1]->type() == nix::nFloat) {
        v = {
            nix::NewValueAs::floating,
            fmod(
                state.forceFloat(*args[0], nix::noPos, "while evaluating the first operand of the modulo operation"),
                state.forceFloat(*args[1], nix::noPos, "while evaluating the second operand of the modulo operation")
            ),
        };
    } else {
        auto x = state.forceInt(*args[0], nix::noPos, "while evaluating the first operand of the modulo operation");
        auto y = state.forceInt(*args[1], nix::noPos, "while evaluating the second operand of the modulo operation");

        v = {
            nix::NewValueAs::integer,
            x.value % y.value
        };
    }
}

static void prim_fds_math_logx(
    nix::EvalState &state, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], nix::noPos);
    state.forceValue(*args[1], nix::noPos);

    auto b = state.forceFloat(*args[0], nix::noPos, "while evaluating the logx");
    auto x = state.forceFloat(*args[1], nix::noPos, "while evaluating the logx");
    v = {
        nix::NewValueAs::floating,
        log(x) / log(b)
    };
}

static void prim_fds_math_sqrt(
    nix::EvalState &state, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], nix::noPos);

    if (args[0]->type() == nix::nFloat) {
        v = {
            nix::NewValueAs::floating,
            sqrt(
                state.forceFloat(*args[0], nix::noPos, "while evaluating the square root")
            )
        };
    } else {
        // FIXME: Check for integer overflow
        auto x = state.forceInt(*args[0], nix::noPos, "while evaluating the square root");
        v = {
            nix::NewValueAs::integer,
            sqrtl(x.value)
        };
    }
}

static void prim_fds_math_cbrt(
    nix::EvalState &state, nix::Value **args, nix::Value &v
) {
    state.forceValue(*args[0], nix::noPos);

    if (args[0]->type() == nix::nFloat) {
        v = {
            nix::NewValueAs::floating,
            cbrt(
                state.forceFloat(*args[0], nix::noPos, "while evaluating the cube root")
            )
        };
    } else {
        auto x = state.forceInt(*args[0], nix::noPos, "while evaluating the cube root");
        v = {
            nix::NewValueAs::integer,
            cbrtl(x.value)
        };
    }
}

std::function<nix::PrimOpImpl> mkPrimOpFloatingValueImpl(
    std::function<double(double)> f, std::string desc
) {
    return [f, desc](
        nix::EvalState &state, nix::Value **args, nix::Value &v
    ) -> nix::Value {
        state.forceValue(*args[0], nix::noPos);
        v = {
            nix::NewValueAs::floating,
            f(
                state.forceFloat(*args[0], nix::noPos, std::format("while evaluating {}", desc))
            )
        };
    };
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
        .fun = mkPrimOpFloatingValueImpl([](double x) { return log(x); }, "natural logarithm"),
    });

    nix::PluginPrimOps::add({
        .name = "__log1p",
        .args = { "X" },
        .doc = R"(
            Return the value of logarithm of 1 + `X`.
        )",
        .fun = mkPrimOpFloatingValueImpl([](double x) { return log1p(x); }, "logarithm of 1p"),
    });

    nix::PluginPrimOps::add({
        .name = "__log2",
        .args = { "X" },
        .doc = R"(
            Return the value of base-2 logarithm of `X`.
        )",
        .fun = mkPrimOpFloatingValueImpl([](double x) { return log2(x); }, "log2"),
    });

    nix::PluginPrimOps::add({
        .name = "__log10",
        .args = { "X" },
        .doc = R"(
            Return the value of base-10 logarithm of `X`.
        )",
        .fun = mkPrimOpFloatingValueImpl([](double x) { return log10(x); }, "log10"),
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

    nix::PluginPrimOps::add({
        .name = "__cos",
        .args = { "X" },
        .doc = R"(
            Return the cosine of `X`.
        )",
        .fun = mkPrimOpFloatingValueImpl([](double x) { return cos(x); }, "cosine"),
    });

    nix::PluginPrimOps::add({
        .name = "__sin",
        .args = { "X" },
        .doc = R"(
            Return the sine of `X`.
        )",
        .fun = mkPrimOpFloatingValueImpl([](double x) { return sin(x); }, "sine"),
    });

    nix::PluginPrimOps::add({
        .name = "__tan",
        .args = { "X" },
        .doc = R"(
            Return the tangent of `X`.
        )",
        .fun = mkPrimOpFloatingValueImpl([](double x) { return tan(x); }, "tangent"),
    });

    nix::PluginPrimOps::add({
        .name = "__acos",
        .args = { "X" },
        .doc = R"(
            Return the arc cosine of `X`.
        )",
        .fun = mkPrimOpFloatingValueImpl([](double x) { return acos(x); }, "arc cosine"),
    });

    nix::PluginPrimOps::add({
        .name = "__asin",
        .args = { "X" },
        .doc = R"(
            Return the arc sine of `X`.
        )",
        .fun = mkPrimOpFloatingValueImpl([](double x) { return asin(x); }, "arc sine"),
    });

    nix::PluginPrimOps::add({
        .name = "__atan",
        .args = { "X" },
        .doc = R"(
            Return the arc tangent of `X`.
        )",
        .fun = mkPrimOpFloatingValueImpl([](double x) { return atan(x); }, "arc tangent"),
    });
}
