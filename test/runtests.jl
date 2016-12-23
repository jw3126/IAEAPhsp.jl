using IAEAPhsp
using Base.Test

datapath(x) = joinpath(Pkg.dir("IAEAPhsp"), "test", "data", x)
# write your own tests here
include("test_raw.jl")
include("test_wrapper.jl")
