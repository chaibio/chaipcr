#===============================================================================

    SFC_model_definitions.jl

    Author: Tom Price
    Date:   June 2019

===============================================================================#

import DataStructures.OrderedDict


@enum SFCModelName take_the_median lin_1ft lin_2ft b4 l4 l4_hbl l4_lbl l4_qbl l4_enl l4_enl_hbl l4_enl_lbl l4_enl_qbl

const SFC_MODEL_BASES = [ ## vector of tuples

## generic

    (
        lin_1ft,
        true,
        ["_x"],
        ["X"],
        ["c0", "c1"],
        [],
        function lin_1ft_func_init_coefs(args...; kwargs...)
            OrderedDict("c0"=>0, "c1"=>0)
        end,
        OrderedDict(
            :f   => "c0 + c1 * _x",
            :inv => "(_x - c0) / c1",
            :bl  => "c0",
            :dr1 => "c1",
            :dr2 => "0"
        )
    ),

    (
        lin_2ft,
        true,
        ["_x1", "_x2"],
        ["X1", "X2"],
        ["c0", "c1", "c2"],
        [],
        function lin_2ft_func_init_coefs(args...; kwargs...)
            OrderedDict("c0"=>0, "c1"=>0, "c2"=>0)
        end,
        OrderedDict(
            :f   => "c0 + c1 * _x1 + c2 * _x2",
            :inv => "0", ## not applicable
            :bl  => "0",
            :dr1 => "[c1, c2]",
            :dr2 => "[0, 0]"
        )
    ),


## amplification curve

    (
        b4,
        false,
        ["_x"],
        ["X"],
        ["b_", "c_", "d_", "e_"],
        [],
        function b4_func_init_coefs(
            X       ::AbstractVector,
            Y       ::AbstractVector,
            epsilon ::Real = 0.001
            )
            Y_min, Y_min_idx = findmin(Y)
            c_ = Y_min - epsilon
            d_ = maximum(Y) + epsilon
            idc_4be = Y_min_idx:length(Y)
            Y_4be = Y[idc_4be]
            Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
            lin1_coefs = linreg(X[idc_4be], Y_logit)
            b_ = lin1_coefs[2]
            e_ = -lin1_coefs[1] / b_
            return OrderedDict("b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_)
        end,
        OrderedDict(
            :f   => "c_ + (d_ - c_) / (1 + exp(b_ * (_x - e_)))",
            :inv => "log((-d_ + _x) / (c_ - _x)) / b_ + e_",
            :bl  => "c_",
            :dr1 =>
                "(b_ * (c_ - d_) * exp(b_ * (e_ + _x)))/(exp(b_ * e_) + exp(b_ * _x))^2",
            :dr2 =>
                "(b_^2 * (c_ - d_) * exp(b_ * (e_ + _x)) * (exp(b_ * e_) - exp(b_ * _x)))/(exp(b_ * e_) + exp(b_ * _x))^3"
        )
    ),

    (
        l4, ## name
        false, ## linear
        ["_x"],
        ["X"],
        ["b_", "c_", "d_", "e_"], ## coef_strs
        ["e_ >= 1e-100"], ## removing bound did not improve Cq accuracy
        function l4_func_init_coefs(
            X       ::AbstractVector,
            Y       ::AbstractVector,
            epsilon ::Real = 0.01
        )
            Y_min, Y_min_idx = findmin(Y)
            c_ = Y_min - epsilon
            d_ = maximum(Y) + epsilon
            idc_4be = Y_min_idx:length(Y)
            Y_4be = Y[idc_4be]
            Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
            lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
            b_ = lin1_coefs[2]
            e_ = exp(-lin1_coefs[1] / b_)
            return OrderedDict("b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_)
        end,
        OrderedDict( ## pred_strs
            :f   => "c_ + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
            :inv => "((e_^b_ * (-d_ + _x))/(c_ - _x))^(1/b_)",
            :bl  => "c_",
            :dr1 => "(b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
            :dr2 =>
                "(b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
        )
    ),

    (
        l4_hbl, ## hyperbolic baseline: increase before log-phase then minimal at plateau (most simple version is -1/x). baseline model `c + bl_k / (e_ - x)` model caused "Ipopt finished with status Restoration_Failed"
        false,
        ["_x"],
        ["X"],
        ["b_", "c_", "d_", "e_", "bl_k", "bl_o"],
        ["e_ >= 1e-100"],
        function l4_hbl_func_init_coefs(
            X       ::AbstractVector,
            Y       ::AbstractVector,
            epsilon ::Real = 0.01
        )
            Y_min, Y_min_idx = findmin(Y)
            c_ = Y_min - epsilon
            d_ = maximum(Y) + epsilon
            idc_4be = Y_min_idx:length(Y)
            Y_4be = Y[idc_4be]
            Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
            lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
            b_ = lin1_coefs[2]
            e_ = exp(-lin1_coefs[1] / b_)
            bl_k = 0
            bl_o = 0
            return OrderedDict(
                "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
                "bl_k"=>bl_k, "bl_o"=>bl_o
            )
        end,
        OrderedDict( ## pred_strs
            :f   =>
                "c_ + bl_k / (_x + bl_o) + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
            :inv => "0", ## not calculated yet
            :bl  => "c_ + bl_k / (_x + bl_o)",
            :dr1 =>
                "-bl_k / (_x + bl_o)^2 + (b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
            :dr2 =>
                "bl_k / (_x + bl_o)^3 + (b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
        )
    ),

    (
        l4_lbl, ## linear baseline
        false,
        ["_x"],
        ["X"],
        ["b_", "c_", "d_", "e_", "k1"],
        ["e_ >= 1e-100"],
        function l4_lbl_func_init_coefs(
            X       ::AbstractVector,
            Y       ::AbstractVector,
            epsilon ::Real = 0.01
        )
            Y_min, Y_min_idx = findmin(Y)
            c_ = Y_min - epsilon
            d_ = maximum(Y) + epsilon
            idc_4be = Y_min_idx:length(Y)
            Y_4be = Y[idc_4be]
            Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
            lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
            b_ = lin1_coefs[2]
            e_ = exp(-lin1_coefs[1] / b_)
            k1 = 0
            return OrderedDict(
                "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
                "k1"=>k1
            )
        end,
        OrderedDict( ## pred_strs
            :f   =>
                "c_ + k1 * _x + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
            :inv => "0", ## not calculated yet
            :bl  => "c_ + k1 * _x",
            :dr1 =>
                "k1 + (b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
            :dr2 =>
                "(b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
        )
    ),

    (
        l4_qbl, ## quadratic baseline
        false,
        ["_x"],
        ["X"],
        ["b_", "c_", "d_", "e_", "k1", "k2"],
        ["e_ >= 1e-100"],
        function l4_qbl_func_init_coefs(
            X       ::AbstractVector,
            Y       ::AbstractVector,
            epsilon ::Real = 0.01
        )
            Y_min, Y_min_idx = findmin(Y)
            c_ = Y_min - epsilon
            d_ = maximum(Y) + epsilon
            idc_4be = Y_min_idx:length(Y)
            Y_4be = Y[idc_4be]
            Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
            lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
            b_ = lin1_coefs[2]
            e_ = exp(-lin1_coefs[1] / b_)
            k1 = 0
            k2 = 0
            return OrderedDict(
                "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
                "k1"=>k1, "k2"=>k2
            )
        end,
        OrderedDict( ## pred_strs
            :f   =>
                "c_ + k1 * _x + k2 * _x^2 + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
            :inv => "0", ## not calculated yet
            :bl  => "c_ + k1 * _x + k2 * _x^2",
            :dr1 =>
                "k1 + 2 * k2 * _x + (b_ * (c_ - d_) * e_^b_ * _x^(-1 + b_)) / (e_^b_ + _x^b_)^2",
            :dr2 =>
                "2 * k2 + (b_ * (c_ - d_) * e_^b_ * _x^(-2 + b_) * ((-1 + b_) * e_^b_ - (1 + b_) * _x^b_))/(e_^b_ + _x^b_)^3"
        )
    ),

    (
        l4_enl, ## name
        false, ## linear
        ["_x"],
        ["X"],
        ["b_", "c_", "d_", "e_"], ## coef_strs
        [], ## coef_cnstrnts
        function l4_enl_func_init_coefs(
            X       ::AbstractVector,
            Y       ::AbstractVector,
            epsilon ::Real = 0.01
        )
            Y_min, Y_min_idx = findmin(Y)
            c_ = Y_min - epsilon
            d_ = maximum(Y) + epsilon
            idc_4be = Y_min_idx:length(Y)
            Y_4be = Y[idc_4be]
            Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
            lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
            b_ = lin1_coefs[2]
            # e_ = -lin1_coefs[1] / b_
            if isnan(b_) || b_ == 0.0
                b_ = NaN_T
                e_ = NaN_T
                c_ = NaN_T
                d_ = NaN_T
            else
                e_ = -lin1_coefs[1] / b_
            end
            return OrderedDict("b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_)
        end,
        OrderedDict( ## pred_strs
            :f   => "c_ + (d_ - c_) / (1 + exp(b_ * (log(_x) - e_)))",
            :inv => "((exp(e_ * b_) * (-d_ + _x))/(c_ - _x))^(1/b_)",
            :bl  => "c_",
            :dr1 => "(b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
            :dr2 =>
                "(b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
        )
    ),

    (
        l4_enl_hbl, ## hyperbolic baseline: increase before log-phase then minimal at plateau (most simple version is -1/x). baseline model `c + bl_k / (e_ - x)` model caused "Ipopt finished with status Restoration_Failed"
        false,
        ["_x"],
        ["X"],
        ["b_", "c_", "d_", "e_", "bl_k", "bl_o"],
        [],
        function l4_enl_hbl_func_init_coefs(
            X       ::AbstractVector,
            Y       ::AbstractVector,
            epsilon ::Real = 0.01
        )
            Y_min, Y_min_idx = findmin(Y)
            c_ = Y_min - epsilon
            d_ = maximum(Y) + epsilon
            idc_4be = Y_min_idx:length(Y)
            Y_4be = Y[idc_4be]
            Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
            lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
            b_ = lin1_coefs[2]
            e_ = exp(-lin1_coefs[1] / b_)
            bl_k = 0
            bl_o = 0
            return OrderedDict(
                "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
                "bl_k"=>bl_k, "bl_o"=>bl_o
            )
        end,
        OrderedDict( ## pred_strs
            :f   =>
                "c_ + bl_k / (_x + bl_o) + (d_ - c_) / (1 + exp(b_ * (log(_x) - e_)))",
            :inv => "0", ## not calculated yet
            :bl  => "c_ + bl_k / (_x + bl_o)",
            :dr1 =>
                "-bl_k / (_x + bl_o)^2 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
            :dr2 =>
                "bl_k / (_x + bl_o)^3 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
        )
    ),

    (
        l4_enl_lbl, ## linear baseline
        false,
        ["_x"],
        ["X"],
        ["b_", "c_", "d_", "e_", "k1"],
        [],
        function l4_enl_lbl_func_init_coefs(
            X       ::AbstractVector,
            Y       ::AbstractVector,
            epsilon ::Real = 0.01
        )
            Y_min, Y_min_idx = findmin(Y)
            c_ = Y_min - epsilon
            d_ = maximum(Y) + epsilon
            idc_4be = Y_min_idx:length(Y)
            Y_4be = Y[idc_4be]
            Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
            lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
            b_ = lin1_coefs[2]
            e_ = exp(-lin1_coefs[1] / b_)
            k1 = 0
            return OrderedDict(
                "b_"=>b_, "c_"=>c_, "d_"=>d_, "e_"=>e_,
                "k1"=>k1
            )
        end,
        OrderedDict( ## pred_strs
            :f   =>
                "c_ + k1 * _x + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
            :inv => "0", ## not calculated yet
            :bl  => "c_ + k1 * _x",
            :dr1 =>
                "k1 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
            :dr2 =>
                "(b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
        )
    ),

    (
        l4_enl_qbl, ## quadratic baseline
        false,
        ["_x"],
        ["X"],
        ["b_", "c_", "d_", "e_", "k1", "k2"],
        [],
        function l4_enl_qbl_func_init_coefs(
            X       ::AbstractVector,
            Y       ::AbstractVector,
            epsilon ::Real = 0.01
        )
            Y_min, Y_min_idx = findmin(Y)
            c_ = Y_min - epsilon
            d_ = maximum(Y) + epsilon
            idc_4be = Y_min_idx:length(Y)
            Y_4be = Y[idc_4be]
            Y_logit = log.((d_ - Y_4be) ./ (Y_4be - c_))
            lin1_coefs = linreg(log.(X[idc_4be]), Y_logit)
            b_ = lin1_coefs[2]
            e_ = exp(-lin1_coefs[1] / b_)
            k1 = 0
            k2 = 0
            return OrderedDict(
                "b_" => b_, "c_" => c_, "d_" => d_, "e_" => e_,
                "k1" => k1, "k2" => k2
            )
        end,
        OrderedDict( ## pred_strs
            :f   =>
                "c_ + k1 * _x + k2 * _x^2 + (d_ - c_) / (1 + exp(b_ * (log(_x) - log(e_))))",
            :inv => "0", ## not calculated yet
            :bl  => "c_ + k1 * _x + k2 * _x^2",
            :dr1 =>
                "k1 + 2 * k2 * _x + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-1 + b_)) / (exp(e_ * b_) + _x^b_)^2",
            :dr2 =>
                "2 * k2 + (b_ * (c_ - d_) * exp(e_ * b_) * _x^(-2 + b_) * ((-1 + b_) * exp(e_ * b_) - (1 + b_) * _x^b_))/(exp(e_ * b_) + _x^b_)^3"
        )
    )
]

## check
const SFC_MODEL_NAMES = map(index(1), SFC_MODEL_BASES)
@assert all(SFC_MODEL_NAMES .== instances(SFCModelName)[2:end]) "incorrect enumeration of SFC model names"