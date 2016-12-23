export Source, Particle, get_particle


immutable Source
    filename::String
    id::SourceId
    access::IAEA_I32
end

function Source(filename, access=1)
    id = ref(IAEA_I32, -1)
    new_source(filename, id, access)
    Source(filename, id, access)
end

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
