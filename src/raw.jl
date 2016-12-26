# Julia wrapper for header: /home/jan/.julia/v0.5/IAEAPhsp/deps/iaea_phsp_Sept2013/iaea_phsp.h
# Automatically generated using Clang.jl wrap_c, version 0.0.0


function iaea_new_source(source_ID,header_file,access,result,hf_length::Cint)
    ccall((:iaea_new_source,IAEA_LIB),Void,(Ptr{IAEA_I32},Cstring,Ptr{IAEA_I32},Ptr{IAEA_I32},Cint),source_ID,header_file,access,result,hf_length)
end

function iaea_get_max_particles(id,_type,n_particle)
    ccall((:iaea_get_max_particles,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I64}),id,_type,n_particle)
end

function iaea_get_maximum_energy(id,Emax)
    ccall((:iaea_get_maximum_energy,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_Float}),id,Emax)
end

function iaea_get_extra_numbers(id,n_extra_float,n_extra_int)
    ccall((:iaea_get_extra_numbers,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32}),id,n_extra_float,n_extra_int)
end

function iaea_set_extra_numbers(id,n_extra_float,n_extra_int)
    ccall((:iaea_set_extra_numbers,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32}),id,n_extra_float,n_extra_int)
end

function iaea_set_type_extralong_variable(id,index,_type)
    ccall((:iaea_set_type_extralong_variable,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32}),id,index,_type)
end

function iaea_set_type_extrafloat_variable(id,index,_type)
    ccall((:iaea_set_type_extrafloat_variable,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32}),id,index,_type)
end

function iaea_get_type_extra_variables(id,result,extralong_types,extrafloat_types)
    ccall((:iaea_get_type_extra_variables,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32}),id,result,extralong_types,extrafloat_types)
end

function iaea_set_constant_variable(id,index,constant)
    ccall((:iaea_set_constant_variable,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_Float}),id,index,constant)
end

function iaea_get_constant_variable(id,index,constant,result)
    ccall((:iaea_get_constant_variable,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_Float},Ptr{IAEA_I32}),id,index,constant,result)
end

function iaea_get_used_original_particles(id,n_indep_particles)
    ccall((:iaea_get_used_original_particles,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I64}),id,n_indep_particles)
end

function iaea_get_total_original_particles(id,number_of_original_particles)
    ccall((:iaea_get_total_original_particles,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I64}),id,number_of_original_particles)
end

function iaea_set_total_original_particles(id,number_of_original_particles)
    ccall((:iaea_set_total_original_particles,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I64}),id,number_of_original_particles)
end

function iaea_set_parallel(id,i_parallel,i_chunk,n_chunk,is_ok)
    ccall((:iaea_set_parallel,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32}),id,i_parallel,i_chunk,n_chunk,is_ok)
end

function iaea_set_record(id,record_num,result)
    ccall((:iaea_set_record,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I64},Ptr{IAEA_I32}),id,record_num,result)
end

function iaea_check_file_size_byte_order(id,result)
    ccall((:iaea_check_file_size_byte_order,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32}),id,result)
end

function iaea_get_particle(id,n_stat,_type,E,wt,x,y,z,u,v,w,extra_floats,extra_ints)
    ccall((:iaea_get_particle,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_I32}),id,n_stat,_type,E,wt,x,y,z,u,v,w,extra_floats,extra_ints)
end

function iaea_write_particle(id,n_stat,_type,E,wt,x,y,z,u,v,w,extra_floats,extra_ints)
    ccall((:iaea_write_particle,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_Float},Ptr{IAEA_I32}),id,n_stat,_type,E,wt,x,y,z,u,v,w,extra_floats,extra_ints)
end

function iaea_destroy_source(source_ID,result)
    ccall((:iaea_destroy_source,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32}),source_ID,result)
end

function iaea_print_header(source_ID,result)
    ccall((:iaea_print_header,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32}),source_ID,result)
end

function iaea_copy_header(source_ID,destiny_ID,result)
    ccall((:iaea_copy_header,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32},Ptr{IAEA_I32}),source_ID,destiny_ID,result)
end

function iaea_update_header(source_ID,result)
    ccall((:iaea_update_header,IAEA_LIB),Void,(Ptr{IAEA_I32},Ptr{IAEA_I32}),source_ID,result)
end
