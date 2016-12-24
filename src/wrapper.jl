export Source, Particle, get_particle, ParticleType

immutable Source
    header_path::String
    id::SourceId
    access::IAEA_I32
    max_particles::Int64
    left_particles::Ref{Int64}
    function Source(header_path, access=1)
        id = ref(IAEA_I32, 1)
        new_source(header_path, id, access)
        max_particles = get_max_particles(id, -1) # -1 counts all particles
        left_particles = Ref(max_particles)
        new(header_path, id, access, max_particles, left_particles)
    end
end

Base.length(s::Source) = value(s.left_particles)
destroy(s::Source) = destroy_source(s.id)

@enum ParticleType photon=1 electron=2 positron=3 neutron=4 proton=5

immutable Particle
    typ::ParticleType
    E::IAEA_Float
    wt::IAEA_Float
    x::IAEA_Float
    y::IAEA_Float
    z::IAEA_Float
    u::IAEA_Float
    v::IAEA_Float
    w::IAEA_Float
    extra_floats::Vector{IAEA_Float}
    extra_ints::Vector{IAEA_I32}
end

for pt in instances(ParticleType)
    fname = Symbol("is", pt)
    @eval $fname(x::Particle) = x.typ == pt
    eval(Expr(:export, fname))
end


function get_particle(s::Source)
    typ, E, wt, x, y, z, u, v, w, extra_floats, extra_ints = get_particle(s.id)
    s.left_particles.x -= 1
    Particle(ParticleType(typ), E, wt, x, y, z, u, v, w, extra_floats, extra_ints)
end

import Base: start, next, done
start(s::Source) = nothing
next(s::Source, state::Void) = get_particle(s), nothing

done(s::Source, state::Void) = length(s) <= 0
