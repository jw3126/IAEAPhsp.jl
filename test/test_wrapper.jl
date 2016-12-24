header_path = datapath("ELDORADO_Co60_10x10_at80p5")

s = Source(header_path)

@show get_particle(s)
@show get_particle(s)

#
# for (i, p) in enumerate(s)
#     if i % 1_000_000 == 0
#         @show i
#         @show length(s)
#         @show s
#         @show p
#     end
# end
