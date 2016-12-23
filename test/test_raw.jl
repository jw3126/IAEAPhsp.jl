datapath(x) = joinpath(Pkg.dir("IAEAPhsp"), "test", "data", x)

header_path = datapath("ELDORADO_Co60_10x10_at80p5")
id = Ref(Int32(-1))
r = Raw.new_source(header_path, id)
@show r
@show Raw.get_max_particles(id, -1)
@show Raw.print_header(id)
