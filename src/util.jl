@generated function ntuple{N}(::Type{Val{N}}, arr)
    args = [:(arr[$i]) for i in 1:N]
    ex = Expr(:tuple, args...)
end