export Source, Particle, get_particle


immutable Source
    filename::String
    id::SourceId
    access::IAEA_I32
    max_particles::Int64
    left_particles::Ref{Int64}
    function Source(filename, access=1)
        id = ref(IAEA_I32, 1)
        new_source(filename, id, access)
        max_particles = get_max_particles(id, -1) # -1 counts all particles
        left_particles = Ref(max_particles)
        new(filename, id, access, max_particles, left_particles)
    end
end

get_used_original_particles(s::Source) = get_used_original_particles(s.id)
Base.length(s::Source) = value(s.left_particles)
destroy(s::Source) = destroy_source(s.id)


immutable Particle
    typ::IAEA_I32
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

function get_particle(s::Source)
    typ, E, wt, x, y, z, u, v, w, extra_floats, extra_ints = get_particle(s.id)
    Particle(typ, E, wt, x, y, z, u, v, w, extra_floats, extra_ints)
end

import Base: start, next, done
start(s::Source) = nothing
function next(s::Source, state::Void)
    p = get_particle(s)
    s.left_particles.x -= 1
    p, nothing
end
done(s::Source, state::Void) = length(s) <= 0
