import IAEAPhsp: unsafe_ntuple, value

@testset "unsafe_ntuple" begin

    @test (1,2,3) === @inferred unsafe_ntuple(Val{3}, [1,2,3])
    @test (1.,2.) === @inferred unsafe_ntuple(Val{2}, [1,2.])

end

@testset "value" begin
    r = Ref(1)
    @test 1 === @inferred value(r)

end
