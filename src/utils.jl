export IAEA_I32, IAEA_I64, IAEA_Float, SourceId, sentinel, ref, value

typealias IAEA_I32 Int32
typealias IAEA_I64 Int64
typealias IAEA_Float Float32
typealias SourceId Ref{IAEA_I32}
sentinel{T <: Integer}(::Type{T}) = typemax(T)
sentinel{T <: AbstractFloat}(::Type{T}) = T(NaN)

ref(T, x=sentinel(T)) = Ref(T(x))
ref{T}(::Type{T}, r::Ref{T}) = r
ref{T, S}(::Type{T}, r::Ref{S}) = error("$S != $T")

value(r::Ref) = r.x
