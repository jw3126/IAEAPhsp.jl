using IAEAPhsp
using Base.Test

datapath(x) = joinpath(@__DIR__, "assets", x)

#include("test_raw.jl")
include("test_util.jl")
include("test_wrapper.jl")
