export Source, Particle, get_particle, ParticleType, readparticles

immutable Allocator{Nf, Ni}
    n_stat::Ref{IAEA_I32}
    _type::Ref{IAEA_I32}
    E::Ref{IAEA_Float}
    wt::Ref{IAEA_Float}
    x::Ref{IAEA_Float}
    y::Ref{IAEA_Float}
    z::Ref{IAEA_Float}
    u::Ref{IAEA_Float}
    v::Ref{IAEA_Float}
    w::Ref{IAEA_Float}
    extra_floats::Vector{IAEA_Float}
    extra_ints::Vector{IAEA_I32}
    function Allocator{Nf, Ni}
        new(
        Ref{IAEA_I32}(1),
        Ref{IAEA_I32}(),
        Ref{IAEA_Float}(),
        Ref{IAEA_Float}(),
        Ref{IAEA_Float}(),
        Ref{IAEA_Float}(),
        Ref{IAEA_Float}(),
        Ref{IAEA_Float}(),
        Ref{IAEA_Float}(),
        Ref{IAEA_Float}(),
        Vector{IAEA_Float}(Nf),
        Vector{IAEA_I32}(Ni)
        )
    end
end

function new_source(header_path::String, id::IAEA_I32, access=1)
    header_file = Ref(header_path.data)
    result = ref(IAEA_I32)
    hf_length = sizeof(header_file)
    iaea_new_source(id, header_file, Ref(IAEA_I32(access)), result, length)
    value(result)
end



immutable Source{Nf, Ni}
    header_path::String
    id::SourceId
    access::IAEA_I32
    max_particles::Int64
    left_particles::Ref{Int64}
    allocator::Allocator{Nf, Ni}

end

function get_extra_numbers(id)
    n_extra_float = Ref(IAEA_I32)()
    n_extra_int = Ref(IAEA_I32)()
    iaea_get_extra_numbers(id,n_extra_float, n_extra_int)
    value(n_extra_float), value(n_extra_int)
end
function get_max_particles(id, _type::Ref)
    n_particle = Ref(IAEA_I64)()
    iaea_get_max_particles(id, _type, n_particle)
    value(n_particle)
end


function Source(header_path, access=1)
    id = ref(IAEA_I32, 1)
    new_source(header_path, id, access)
    type_all = Ref(IAEA_I64(-1))
    max_particles = get_max_particles(id, type_all)
    left_particles = Ref(max_particles)
    Nf, Ni = get_extra_numbers(id)
    allocator = Allocator{Nf, Ni}()
    Source{Nf, Ni}(header_path, id, access, max_particles, left_particles, allocator)
end



Base.length(s::Source) = value(s.left_particles)
destroy(s::Source) = destroy_source(s.id)

@enum ParticleType photon=1 electron=2 positron=3 neutron=4 proton=5

immutable Particle{Nf, Ni}
    particle_type::ParticleType
    E::IAEA_Float
    wt::IAEA_Float
    x::IAEA_Float
    y::IAEA_Float
    z::IAEA_Float
    u::IAEA_Float
    v::IAEA_Float
    w::IAEA_Float
    extra_floats::NTuple{Nf, IAEA_Float}
    extra_ints::NTuple{Ni, IAEA_I32}
end

for pt in instances(ParticleType)
    fname = Symbol("is", pt)
    @eval $fname(x::Particle) = x.typ == pt
    eval(Expr(:export, fname))
end

function allocate_next_particle!(s::Source)
    a = s.allocator
    get_particle(id,a.n_stat,a._type,a.E,a.wt,a.x,a.y,a.z,a.u,a.v,a.w,a.extra_floats,a.extra_ints)
end
function get_particle{Nf, Ni}(a::Allocator{Nf, Ni})
    Particle{Nf, Ni}(
    a._type |> value |> ParticleType,
    a.E |> value,
    a.wt |> value,
    a.x |> value,
    a.y |> value,
    a.z |> value,
    a.u |> value,
    a.v |> value,
    a.w |> value,
    ntuple(Val{Nf}, a.extra_floats),
    ntuple(Val{Nf}, a.extra_ints),
    )
end
function get_particle(s::Source)
    allocate_next_particle!(s)
    get_particle(s.allocator)
end

import Base: start, next, done
start(s::Source) = nothing
next(s::Source, state::Void) = get_particle(s), nothing

done(s::Source, state::Void) = length(s) <= 0

function destroy_source(s::Source)
    result = Ref{IAEA_I32}
    iaea_destroy_source(s.id, result)
    value(result)
end

@noinline readparticles(s::Source) = collect(s)

function readparticles(path)
    s = Source(path)
    readparticles(s)
    destroy_source(s)
    ret
end
