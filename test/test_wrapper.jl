import IAEAPhsp: allocate_next_particle!, value, ParticleType, Allocator
@testset "inference" begin

    a = Allocator{1,2}()
    a._type.x = 1 # photon
    @inferred get_particle(a)

end


header_path = datapath("ELDORADO_Co60_10x10_at80p5")

s = Source(header_path)

@time readparticles(s)
