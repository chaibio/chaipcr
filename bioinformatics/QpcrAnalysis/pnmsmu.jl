## polynomial model smoother, borrowed from Friedman's super smoother (Firedman 1984):
## fit a polynomial model to the data in a sliding window of length approximately
## `span_frac * 2 * (maximum(x) - minimum(x))` on x axis,
## set the y value at the middle point of the sliding window
## as the predicted value by the polynomial model.


# Top-level function
function pnmsmu(
    X ::AbstractVector,
    Y ::AbstractVector,
    span_frac ::Real=0.05,
    polynomial_degree ::Integer=1, ## polynomial_degree <= 1 will yield same results as == 1
    x_sortedb ::Bool=true,
    x_evenly_spacedb ::Bool=true
)
    if ndims(X) > 1 || ndims(Y) > 1
        error(logger, "X and Y must be 1-dimensional")
    end

    dlen = length(X)

    if dlen < 5 || length(Y) != dlen
        error(logger, "X and Y must be equal and >= 5 in length")
    end

    if !x_sorted
        indice_sorted = sortperm(X)
        indice_back = sortperm(indice_sorted)
        X = X[indice_sorted]
        Y = Y[indice_sorted]
    end

    # sel_idc = selected indices
    if x_evenly_spaced ## faster
        span_dp = round(Int, span_frac * dlen) ## dp = data points
        sel_idc_vec = map(i -> giis_even(dlen, i, span_dp), 1:dlen)
    else
        span_x = span_frac * (maximum(X) - minimum(X))
        sel_idc_vec = map(i -> giis_uneven(X, i, span_x), 1:dlen)
    end

    ## construct `x_pn_df` for to use `pnm_lm`
    # x_pn_df = DataFrame(d1 = X)
    # for d in 2:polynomial_degree ## nothing happends when polynomial_degree == 1
    #     x_pn_df[parse("d$d")] = X .^ d
    # end

    x_ary = hcat(map(d -> X .^ d, 1:polynomial_degree)...)

    Y_smu = map(1:dlen) do i
        sel_idc = sel_idc_vec[i]
        coefs = pnm_lsq(x_ary[sel_idc,:], Y[sel_idc])
        local_x_vec = hcat(1, x_ary[i,:])
        return *(local_x_vec, coefs)[1] ## *(array_1_m, vector_m) == vector_1
    end ## do i

    return x_sorted ? Y_smu : Y_smu[indice_back]
end


## functions called by 'pnmsmu'

## functions to fit a polynomial model on using x to predict y

## using `lm` from "GLM". ~14 sec
function pnm_lm(x_pn_df ::DataFrame, Y ::AbstractVector)
    xy_df = copy(x_pn_df)
    xy_df[:y] = Y
    fml = Formula(:y, Expr(:call, :+, 1, x_pn_df.colindex.names...)) ## note: Formula can also be constructed as eval(parse(computated_str))
    return coef(lm(fml, xy_df))
end

## using native least square method. ~4 sec when using DataFrame, 2-3 sec when using Array
function pnm_lsq(x_ary ::AbstractArray, Y ::AbstractVector)
    x_w1 = hcat(ones(size(x_ary)[1]), x_ary)
    x_w1_T = transpose(x_w1)
    coefs = *(inv(x_w1_T * x_w1), x_w1_T, Y)
end


#
