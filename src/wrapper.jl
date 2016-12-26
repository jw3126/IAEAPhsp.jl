export Source, Particle, get_particle, ParticleType, readparticles
import Base: RefValue
immutable Allocator{Nf, Ni}
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
    function Allocator()
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

function new_source(header_path::String, id::Ref{IAEA_I32}, access=1)
    header_file = header_path.data |> pointer |> Cstring #Ref(header_path.data)
    result = Ref{IAEA_I32}()
    hf_length = header_path.data |> sizeof |> Cint
    iaea_new_source(id, header_path, Ref(IAEA_I32(access)), result, hf_length)
    value(result)
end



immutable Source{Nf, Ni}
    header_path::String
    id::RefValue{IAEA_I32}
    access::IAEA_I32
    max_particles::Int64
    left_particles::RefValue{Int64}
    allocator::Allocator{Nf, Ni}

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


function Source(header_path, access=1)
    id = Ref{IAEA_I32}(1)
    new_source(header_path, id, access)
    type_all = Ref{IAEA_I32}(-1)
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
    #iaea_get_particle(id,n_stat,_type,E,wt,x,y,z,u,v,w,extra_floats,extra_ints)
    iaea_get_particle(s.id,a.n_stat,a._type,
    a.E,a.wt,
    a.x,a.y,a.z,
    a.u,a.v,a.w,
    a.extra_floats,
    a.extra_ints)
    s.left_particles.x -= IAEA_I32(1)

end
function get_particle{Nf, Ni}(a::Allocator{Nf, Ni})
    particle_type = a._type |> value |> ParticleType
    E = a.E |> value
    wt = a.wt |> value
    x = a.x |> value
    y = a.y |> value
    z = a.z |> value
    u = a.u |> value
    v = a.v |> value
    w = a.w |> value
    extra_floats = unsafe_ntuple(Val{Nf}, a.extra_floats)
    extra_ints = unsafe_ntuple(Val{Ni}, a.extra_ints)

    Particle{Nf, Ni}(
    particle_type,
    E,
    wt,
    x,
    y,
    z,
    u,
    v,
    w,
    extra_floats,
    extra_ints
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

@noinline function readparticles{Nf, Ni}(s::Source{Nf, Ni})
    ret = Particle{Nf, Ni}[]
    sizehint!(ret, s.left_particles.x)
    for p in s
        push!(ret, p)
    end
    ret
end

function readparticles(path)
    s = Source(path)
    readparticles(s)
    destroy_source(s)
    ret
end
