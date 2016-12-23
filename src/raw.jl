module Raw

typealias IAEA_I32 Int32
typealias IAEA_I64 Int64
typealias IAEA_Float Float32
typealias SourceId Ref{IAEA_I32}
const lib = joinpath(Pkg.dir("IAEAPhsp"), "deps", "iaea_phsp_Sept2013", "libiaea_phsp.so")

@assert ispath(lib)

sentinel{T <: Integer}(::Type{T}) = typemax(T)
sentinel{T <: AbstractFloat}(::Type{T}) = T(NaN)

ref(T, x=sentinel(T)) = Ref(T(x))
ref{T}(::Type{T}, r::Ref{T}) = r
ref{T, S}(::Type{T}, r::Ref{S}) = error("$S != $T")

value(r::Ref) = r.x

function new_source(header_path::String, id::SourceId, access=1)
    header_file = Ref(header_path.data)
    result = ref(IAEA_I32)
    hf_length = sizeof(header_file)

    ccall(
    (:iaea_new_source, lib),
    Void, (Ptr{IAEA_I32}, Ptr{UInt8}, Ptr{IAEA_I32}, Ptr{IAEA_I32}, Cint),
    id, header_file, ref(IAEA_I32, access), result, hf_length
    )
    value(result)
end

function get_max_particles(id::SourceId, typ)
    n_particle = ref(IAEA_I64)

    ccall(
    (:iaea_get_max_particles, lib),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_I32}, Ptr{IAEA_I64}),
    id, ref(IAEA_I32, typ), n_particle
    )
    value(n_particle)
end


function get_maximum_energy(id::SourceId)
    Emax = ref(IAEA_Float)

    ccall(
    (:iaea_get_maximum_energy, lib),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_Float}),
    id, Emax
    )
    value(Emax)
end

function print_header(id::SourceId)
    n_particle = ref(IAEA_I64)

    result = ref(IAEA_I32)
    ccall(
    (:iaea_print_header, lib),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_I32}),
    id, result
    )
    value(result)
end




end
