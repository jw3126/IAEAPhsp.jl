@generated function unsafe_ntuple{N}(::Type{Val{N}}, arr)
    args = [:(arr[$i]) for i in 1:N]
    ex = Expr(:tuple, args...)
end
value(r::Ref) = r.x
