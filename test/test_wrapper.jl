import IAEAPhsp: allocate_next_particle!, value, ParticleType, Allocator, _get_particle
@testset "inference" begin

    a = Allocator{1,2}()
    a._type.x = 1 # photon
    @inferred _get_particle(a)

end

@testset "destroy" begin
    path = datapath("waterbox")
    
    s = Source(path)
    n = length(s)
    @test n > 0
    particles = @inferred collect(s)
    @test n == length(particles)
    @test !isempty(particles)
    @test length(s) == 0
    @test isempty(collect(s))
    destroy(s)
    @test_throws ArgumentError destroy(s)
    s = Source(path)
    @test particles == collect(s)
end
