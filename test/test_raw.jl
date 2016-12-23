import IAEAPhsp: new_source, get_max_particles, get_particle, destroy_source, get_extra_numbers, print_header

header_path = datapath("ELDORADO_Co60_10x10_at80p5")
id = Ref(Int32(-1))
r = new_source(header_path, id)
@show r
@show get_max_particles(id, -1)
@show print_header(id)
@show get_particle(id)
@show get_particle(id)

@show get_particle(id)
@show get_extra_numbers(id)
@show destroy_source(id)
