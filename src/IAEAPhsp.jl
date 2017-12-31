__precompile__(true)
module IAEAPhsp

using Revise
import LibIAEAPhsp
using LibIAEAPhsp: IAEA_I32, IAEA_I64, IAEA_Float
const L = LibIAEAPhsp

using ArgCheck
export Source, Particle
export ParticleType, photon, electron, positron, proton, neutron
export AccessMode, Read, Write, Append
export destroy, isalive, writeparticle

import Base: RefValue
function check_result(f, result::Ref{IAEA_I32})
    if result[] < 0
        error("Something went wrong in $f. Got result=$result")
    end
end

function new_source(path::String, id::Ref{IAEA_I32}, access=1)
    header_file = path |> Vector{UInt8} |> pointer |> Cstring
    result = Ref{IAEA_I32}(0)
    hf_length = path |> Vector{UInt8} |> sizeof |> Cint
    L.iaea_new_source(id, path, Ref(IAEA_I32(access)), result, hf_length)
    check_result(L.iaea_new_source, result)
end
function get_extra_numbers(id::Ref)
    nf = Ref{IAEA_I32}()
    ni = Ref{IAEA_I32}()
    L.iaea_get_extra_numbers(id,nf, ni)
    Int(nf[]), Int(ni[])
end
function get_max_particles(id::Ref, _type::Ref)
    n_particle = Ref{IAEA_I64}()
    L.iaea_get_max_particles(id, _type, n_particle)
    n_particle[]
end

# talking to iaea library is via C functions, whose arguments
# are lots of pointers to numbers. We allocate memory once with this Allocator type
struct Allocator{Nf, Ni}
    n_stat::RefValue{IAEA_I32}
    typ::RefValue{IAEA_I32}
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
        Ref{IAEA_I32}(-999),
        Ref{IAEA_Float}(NaN),
        Ref{IAEA_Float}(NaN),
        Ref{IAEA_Float}(NaN),
        Ref{IAEA_Float}(NaN),
        Ref{IAEA_Float}(NaN),
        Ref{IAEA_Float}(NaN),
        Ref{IAEA_Float}(NaN),
        Ref{IAEA_Float}(NaN),
        fill!(Vector{IAEA_Float}(Nf), NaN),
        fill!(Vector{IAEA_I32}(Ni), -999)
        )
    end
end

@enum AccessMode Read=1 Write=2 Append=3

struct Source{Nf, Ni}
    path::String
    id::RefValue{IAEA_I32}
    access::AccessMode
    max_particles::Int64
    left_particles::RefValue{Int64}
    allocator::Allocator{Nf, Ni}
    alive::RefValue{Bool}
end

const CURRENT_SOURCE_ID = Ref(IAEA_I32(0))

function Source(path, access::AccessMode)
    if access == Read
        @argcheck ispath(path*".IAEAheader")
        @argcheck ispath(path*".IAEAphsp")
    end

    id = Ref(CURRENT_SOURCE_ID[])
    
    CURRENT_SOURCE_ID[] += 1
    res = new_source(path, id, IAEA_I32(access))
    if access == Write
        L.iaea_set_total_original_particles(id,Ref(IAEA_I64(-1)))
    end
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
    function Particle{Nf, Ni}(typ, E, wt, x,y,z, u,v,w, extra_floats, extra_ints) where {Nf, Ni}
        @argcheck (u^2 + v^2 + w^2) ≈ 1
        @argcheck E >= 0.
        @argcheck wt >= 0.
        new(typ, E, wt, x,y,z, u,v,w, extra_floats, extra_ints)
    end
end
function Particle(typ,E,wt, x,y,z, u,v,w, ef::NTuple{Nf}, ei::NTuple{Ni}) where {Nf, Ni}
    Particle{Nf, Ni}(typ,E,wt, x,y,z, u,v,w, ef, ei)

end

function Base.isapprox(p1::Particle, p2::Particle)
    p1.particle_type == p2.particle_type &&
    isapprox(p1.E, p2.E) &&
    isapprox(p1.wt, p2.wt) &&
    isapprox(p1.x, p2.x) &&
    isapprox(p1.y, p2.y) &&
    isapprox(p1.z, p2.z) &&
    isapprox(p1.u, p2.u) &&
    isapprox(p1.v, p2.v) &&
    isapprox(p1.w, p2.w) &&
    p1.extra_floats == p2.extra_floats &&
    p1.extra_ints == p2.extra_ints
end

for pt in instances(ParticleType)
    fname = Symbol("is", pt)
    @eval $fname(x::Particle) = x.typ == pt
    eval(Expr(:export, fname))
end


function write_to_allocator!(a::Allocator{Nf, Ni}, p::Particle{Nf, Ni}) where {Nf, Ni}
    a.typ[] = p.particle_type
    a.E[] = p.E
    a.wt[] = p.wt
    a.x[] = p.x
    a.y[] = p.y
    a.z[] = p.z
    a.u[] = p.u
    a.v[] = p.v
    a.w[] = p.w
    copy!(a.extra_floats, p.extra_floats)
    copy!(a.extra_ints, p.extra_ints)
    a
end

function write_current_particle(s::Source)
    a = s.allocator
    @argcheck a.n_stat[] >= 0
    L.iaea_write_particle(s.id, a.n_stat,
        a.typ,
        a.E,a.wt,
        a.x,a.y,a.z,
        a.u,a.v,a.w,
        a.extra_floats,
        a.extra_ints)
    @assert a.n_stat[] != -1
end

function writeparticle(s::Source, p::Particle)
    @argcheck s.access == Write
    write_to_allocator!(s, p)
    write_current_particle(s)
end

function write_to_allocator!(s::Source, p::Particle)
    @argcheck s.access == Write
    write_to_allocator!(s.allocator, p)
    s
end

function allocate_next_particle!(s::Source)
    @argcheck s.access == Read
    @argcheck isalive(s)
    a = s.allocator
    L.iaea_get_particle(s.id,a.n_stat,a.typ,
    a.E,a.wt,
    a.x,a.y,a.z,
    a.u,a.v,a.w,
    a.extra_floats,
    a.extra_ints)
    s.left_particles.x -= IAEA_I32(1)
end
function _get_particle{Nf, Ni}(a::Allocator{Nf, Ni})
    Particle{Nf, Ni}(
        ParticleType(a.typ[]),
        a.E[],
        a.wt[],
        a.x[],
        a.y[],
        a.z[],
        a.u[],
        a.v[],
        a.w[],
        NTuple{Nf, IAEA_Float}(a.extra_floats...),
        NTuple{Ni, IAEA_I32}(a.extra_ints)
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
length(s::Source) = s.left_particles[]
eltype(s::Source{Nf, Ni}) where {Nf, Ni} = Particle{Nf, Ni}

function destroy(s::Source)
    @argcheck isalive(s)
    s.alive[] = false
    result = Ref{IAEA_I32}(0)
    L.iaea_destroy_source(s.id, result)
    check_result(L.iaea_destroy_source, result)
end

end # module
