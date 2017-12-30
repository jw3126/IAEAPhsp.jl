const IAEA_LIB_FOLDER = joinpath(Pkg.dir("IAEAPhsp"), "deps", "src")
const IAEA_LIB = joinpath(IAEA_LIB_FOLDER, "libiaea_phsp.so")
@assert ispath(IAEA_LIB)

const IAEA_I32   = Int32
const IAEA_I64   = Int64
const IAEA_Float = Float32
