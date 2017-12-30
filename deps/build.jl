url = "https://www-nds.iaea.org/phsp/software/iaea_phsp_Sept2013.zip"
dir = joinpath(@__DIR__, "src")
rm(dir, force=true, recursive=true)
mkdir(dir)
path = joinpath(dir, "blob")
download(url, path)
run(Cmd(`unzip $path`, dir=dir))
#run(Cmd(`make all --just-print`, dir=dir))

cmds = [
`g++ -O2 -fPIC -c -o iaea_header.o iaea_header.cpp`,
`g++ -O2 -fPIC -c -o iaea_phsp.o iaea_phsp.cpp`,
`g++ -O2 -fPIC -c -o iaea_record.o iaea_record.cpp`,
`g++ -O2 -fPIC -c -o utilities.o utilities.cpp`,
`g++ -O2 -fPIC -c -o iaea_event_generator.o iaea_event_generator.cpp`,
`g++ -O2 -fPIC -shared -o libiaea_phsp.so iaea_header.o iaea_phsp.o iaea_record.o utilities.o iaea_event_generator.o -ldl`,
]
for cmd in cmds
    run(Cmd(cmd, dir=dir))
end
