using ArgCheck
export Source, Particle, get_particle, ParticleType, destroy, isalive

import Base: RefValue

function new_source(path::String, id::Ref{IAEA_I32}, access=1)
    header_file = path |> Vector{UInt8} |> pointer |> Cstring
    result = Ref{IAEA_I32}()
    hf_length = path |> Vector{UInt8} |> sizeof |> Cint
    iaea_new_source(id, path, Ref(IAEA_I32(access)), result, hf_length)
    value(result)
end
function get_extra_numbers(id)
    nf = Ref{IAEA_I32}()
    ni = Ref{IAEA_I32}()
    iaea_get_extra_numbers(id,nf, ni)
    Int(value(nf)), Int(value(ni))  # NTuple{N,...} wants Int and not Int32
end
function get_max_particles(id, _type::Ref)
    n_particle = Ref{IAEA_I64}()
    iaea_get_max_particles(id, _type, n_particle)
    value(n_particle)
end

# talking to iaea library is via C functions, whose arguments
# are lots of pointers to numbers. We allocate memory once with this Allocator type
struct Allocator{Nf, Ni}
    n_stat::RefValue{IAEA_I32}
    _type::RefValue{IAEA_I32}
    E::RefValue{IAEA_Float}
    wt::RefValue{IAEA_Float}
    x::RefValue{IAEA_Float}
    y::RefValue{IAEA_Float}
    z::RefValue{IAEA_Float}
    u::RefValue{IAEA_Float}
    v::RefValue{IAEA_Float}
    w::RefValue{IAEA_Float}
    extra_floats::Vector{IAEA_Float}
    extra_ints::Vector{IAEA_I32}
    function Allocator{Nf, Ni}() where {Nf, Ni}
        new(Ref{IAEA_I32}(1),
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


struct Source{Nf, Ni}
    path::String
    id::RefValue{IAEA_I32}
    access::IAEA_I32
    max_particles::Int64
    left_particles::RefValue{Int64}
    allocator::Allocator{Nf, Ni}
    alive::RefValue{Bool}
end

function Source(path, access=1)
    @argcheck ispath(path*".IAEAheader")
    @argcheck ispath(path*".IAEAphsp")

    id = Ref{IAEA_I32}(1)
    new_source(path, id, access)
    type_all = Ref{IAEA_I32}(-1)
    max_particles = get_max_particles(id, type_all)
    left_particles = Ref(max_particles)
    Nf, Ni = get_extra_numbers(id)
    allocator = Allocator{Nf, Ni}()
    alive = Ref(true)
    Source{Nf, Ni}(path, id, access, max_particles, left_particles, allocator, alive)
end
isalive(s::Source) = s.alive[]

@enum ParticleType photon=1 electron=2 positron=3 neutron=4 proton=5

struct Particle{Nf, Ni}
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
    @argcheck isalive(s)
    a = s.allocator
    #iaea_get_particle(id,n_stat,_type,E,wt,x,y,z,u,v,w,extra_floats,extra_ints)
    iaea_get_particle(s.id,a.n_stat,a._type,
    a.E,a.wt,
    a.x,a.y,a.z,
    a.u,a.v,a.w,
    a.extra_floats,
    a.extra_ints)
    s.left_particles.x -= IAEA_I32(1)
end
function _get_particle{Nf, Ni}(a::Allocator{Nf, Ni})
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
    unsafe_ntuple(Val{Nf}, a.extra_floats),
    unsafe_ntuple(Val{Ni}, a.extra_ints)
    )
end
function get_particle(s::Source)
    allocate_next_particle!(s)
    _get_particle(s.allocator)
end

import Base: start, next, done, length, eltype

start(s::Source) = nothing
next(s::Source, state::Void) = get_particle(s), nothing
done(s::Source, state::Void) = length(s) <= 0
length(s::Source) = value(s.left_particles)
eltype(s::Source{Nf, Ni}) where {Nf, Ni} = Particle{Nf, Ni}

function destroy(s::Source)
    @argcheck isalive(s)
    s.alive[] = false
    result = Ref{IAEA_I32}()
    iaea_destroy_source(s.id, result)
    value(result)
end

function Base.collect(s::Source)
    ret = eltype(s)[]
    sizehint!(ret, length(s))
    for p in s
        push!(ret, p)
    end
    ret
end
