using IAEAPhsp
using Base.Test

@testset "write read" begin
    path = "some_file"
    s = Source(path, Write)
    u,v,w = normalize!(randn(Float32,3))
    p = Particle(photon, 1f0,2f0,3f0,4f0,5f0,u,v,w, (), (Int32(13),))
    writeparticle(s, p)
    destroy(s)
    
    s2 = Source(path, Read)
    
    @test length(s2) == 1
    p2 = first(s2)
    @test p2 ≈ p
    rm(path*".IAEAphsp", force=true)
    rm(path*".IAEAheader", force=true)
end
