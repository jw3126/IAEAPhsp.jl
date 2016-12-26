using Clang.wrap_c

include("constants.jl")
headers = [joinpath(LIB_FOLDER, "iaea_phsp.h")]
wc = wrap_c.init(
headers=headers,
output_file="raw.jl",
header_library = _ -> :IAEA_LIB,
)
wc.headers = headers
run(wc)
