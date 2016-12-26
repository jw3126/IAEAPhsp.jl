
const IAEA_LIB_FOLDER = joinpath(Pkg.dir("IAEAPhsp"), "deps", "iaea_phsp_Sept2013")
const IAEA_LIB = joinpath(IAEA_LIB_FOLDER, "libiaea_phsp.so")
@assert ispath(IAEA_LIB)

typealias IAEA_I32 Int32
typealias IAEA_I64 Int64
typealias IAEA_Float Float32
