# export new_source, get_max_particles, get_maximum_energy,
# get_extra_numbers, get_particle, destroy_source, print_header

const LIB_IAEA = joinpath(Pkg.dir("IAEAPhsp"), "deps", "iaea_phsp_Sept2013", "libiaea_phsp.so")
@assert ispath(LIB_IAEA)



function new_source(header_path::String, id::SourceId, access=1)
    header_file = Ref(header_path.data)
    result = ref(IAEA_I32)
    hf_length = sizeof(header_file)

    ccall(
    (:iaea_new_source, LIB_IAEA),
    Void, (Ptr{IAEA_I32}, Ptr{UInt8}, Ptr{IAEA_I32}, Ptr{IAEA_I32}, Cint),
    id, header_file, ref(IAEA_I32, access), result, hf_length
    )
    value(result)
end

function get_max_particles(id::SourceId, typ)
    n_particle = ref(IAEA_I64)

    ccall(
    (:iaea_get_max_particles, LIB_IAEA),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_I32}, Ptr{IAEA_I64}),
    id, ref(IAEA_I32, typ), n_particle
    )
    value(n_particle)
end


function get_maximum_energy(id::SourceId)
    Emax = ref(IAEA_Float)

    ccall(
    (:iaea_get_maximum_energy, LIB_IAEA),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_Float}),
    id, Emax
    )
    value(Emax)
end

function print_header(id::SourceId)
    n_particle = ref(IAEA_I64)

    result = ref(IAEA_I32)
    ccall(
    (:iaea_print_header, LIB_IAEA),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_I32}),
    id, result
    )
    value(result)
end

function get_extra_numbers(id::SourceId)
    n_extra_float = ref(IAEA_I32)
    n_extra_int = ref(IAEA_I32)
    ccall(
    (:iaea_get_extra_numbers, LIB_IAEA),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_I32}, Ptr{IAEA_I32}),
    id, n_extra_float, n_extra_int
    )
    value(n_extra_float), value(n_extra_int)
end

# TODO
# /*************************************************************************
# * Number of additional floats and integers to be stored
# *
# * Set the number of additional floats in n_extra_float and the number
# * of additional integers in n_extra_integer for the source with Id id
# * to be stored in the corresponding file.
# *************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_set_extra_numbers(const IAEA_I32 *id, IAEA_I32 *n_extra_float,
#                                   IAEA_I32 *n_extra_int);

# TODO
# /*******************************************************************************
# * Set a type type of the extra long variable corresponding to the "index" number
# * for a corresponding header of the phsp "id". Index is running from zero.
# *
# * The current list of types for extra long variables is:
# *   0: User defined generic type
# *   1: Incremental history number (EGS,PENELOPE)
# *      = 0 indicates a nonprimary particle event
# *      > 0 indicates a primary particle. The value is equal to the number of
# *          primaries particles employed to get to this history after the last
# *          primary event was recorded.
# *   2: LATCH (EGS)
# *   3: ILB5 (PENELOPE)
# *   4: ILB4 (PENELOPE)
# *   5: ILB3 (PENELOPE)
# *   6: ILB2 (PENELOPE)
# *   7: ILB1 (PENELOPE)
# *   more to be defined
# *
# * Usually called before writing phsp header to set the type of extra long
# * variables to be stored. It must be called once for every extralong variable.
# *
# * type = -1 means the source's header file does not exist
# *           or source was not properly initialized (call iaea_new_...)
# * type = -2 means the index is out of range ( 0 <= index < NUM_EXTRA_LONG )
# * type = -3 means the type to be set is out of range
# *           ( 1 <= type < MAX_NUMB_EXTRALONG_TYPES )
# *******************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_set_type_extralong_variable(const IAEA_I32 *id,
#                                       const IAEA_I32 *index,
#                                             IAEA_I32 *type);

# TODO
# /********************************************************************************
# * Set a type type of the extra float variable corresponding to the "index" number
# * for a corresponding header of the phsp "id". Index is running from zero.
# *
# * The current list of types for extra float variables is:
# *   1: XLAST (x coord. of the last interaction)
# *   2: YLAST (y coord. of the last interaction)
# *   3: ZLAST (z coord. of the last interaction)
# *   more to be defined
# *
# * Usually called before writing phsp header to set the type of extra float
# * variables to be stored. It must be called once for every extra float variable.
# *
# * type = -1 means the source's header file does not exist
# *           or source was not properly initialized (call iaea_new_...)
# * type = -2 means the index is out of range ( 0 <= index < NUM_EXTRA_FLOAT )
# * type = -3 means the type to be set is out of range
# *           ( 1 <= type < MAX_NUMB_EXTRAFLOAT_TYPES )
# *******************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_set_type_extrafloat_variable(const IAEA_I32 *id,
#                                        const IAEA_I32 *index,
#                                              IAEA_I32 *type);

# /****************************************************************************
# * Get a type type of all extra variables from a header of the phsp "id".
# *
# * extralong_types[] AND extrafloat_types[] must have a dimension bigger than
# * MAX_NUMB_EXTRALONG_TYPES and MAX_NUMB_EXTRAFLOAT_TYPES correspondingly
# *
# * The current list of types for extra long variables is:
# *   0: User defined generic type
# *   1: Incremental history number (EGS,PENELOPE)
# *      = 0 indicates a nonprimary particle event
# *      > 0 indicates a primary particle. The value is equal to the number of
# *          primaries particles employed to get to this history after the last
# *          primary event was recorded.
# *   2: LATCH (EGS)
# *   3: ILB5 (PENELOPE)
# *   4: ILB4 (PENELOPE)
# *   5: ILB3 (PENELOPE)
# *   6: ILB2 (PENELOPE)
# *   7: ILB1 (PENELOPE)
# *   more to be defined
# *
# * The current list of types for extra float variables is:
# *   1: XLAST (x coord. of the last interaction)
# *   2: YLAST (y coord. of the last interaction)
# *   3: ZLAST (z coord. of the last interaction)
# *   more to be defined
# *
# * Usually called before reading phsp header to know the type of extra long
# * variables to be read. It must be called once for every extra float variable.
# *
# * result = -1 means the source's header file does not exist
# *             or source was not properly initialized (call iaea_new_...)
# *******************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_get_type_extra_variables(const IAEA_I32 *id, IAEA_I32 *result,
#       IAEA_I32 extralong_types[], IAEA_I32 extrafloat_types[]);


# /*************************************************************************
# * Set variable corresponding to the "index" number to a "constant" value
# * for a corresponding header of the phsp "id". Index is running from zero.
# *
# *       (Usually called as needed before MC loop started)
# *
# *                index  =  0 1 2 3 4 5 6
# *          corresponds to  x,y,z,u,v,w,wt
# *
# * Usually called before writing phsp files to set those variables which
# * are not going to be stored. It must be called once for every variable
# *
# * constant = -1 means the source's header file does not exist
# *               or source was not properly initialized (call iaea_new_...)
# * constant = -2 means the index is out of range ( 0 <= index < 7 )
# *************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_set_constant_variable(const IAEA_I32 *id, const IAEA_I32 *index,
#                                 IAEA_Float *constant);
#
# /*************************************************************************
# * Get value of constant corresponding to the "index" number
# * for a corresponding header of the phsp "id". Index is running from zero.
# *
# *                index  =  0 1 2 3 4 5 6
# *          corresponds to  x,y,z,u,v,w,wt
# *
# * Usually called when reading phsp header info.
# * It must be called once for every variable
# *
# *  result = -1 means the source's header file does not exist
# *               or source was not properly initialized (call iaea_new_...)
# *  result = -2 means the index is out of range ( 0 <= index < 7 )
# *  result = -3 means that the parameter indicated by index is not a constant
# *************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_get_constant_variable(const IAEA_I32 *id, const IAEA_I32 *index,
#                                  IAEA_Float *constant, IAEA_I32 *result);


function get_used_original_particles(id::SourceId)
    n_indep_particles = ref(IAEA_I64)
    ccall(
    (:iaea_get_used_original_particles, LIB_IAEA),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_I64}),
    id, n_indep_particles
    )
    value(n_indep_particles)
end

function get_total_original_particles(id::SourceId)
    number_of_original_particles = ref(IAEA_I64)
    ccall(
    (:iaea_get_total_original_particles, LIB_IAEA),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_I64}),
    id, number_of_original_particles
    )
    value(number_of_original_particles)
end

# /*****************************************************************************
# * Set Total Number of Original Particles for the Source with Id id.
# *
# * For a typical linac it should be equal to the total number of electrons
# * incident on the primary target.
# *
# * Set number_of_original_particles to negative if such source does not exist.
# ******************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_set_total_original_particles(const IAEA_I32 *id,
#                                        IAEA_I64 *number_of_original_particles);

# /**************************************************************************
# * Partitioning for parallel runs
# *
# * i_parallel is the job number, i_chunk the calculation chunk,
# * n_chunk the total number of calculation chunks. This function
# * should divide the available phase space of source with Id id
# * into n_chunk equal portions and from now on deliver particles
# * from the i_chunkth portion. (i_chunk must be between 1 and n_chunk)
# * The extra parameter i_parallel is needed
# * for the cases where the source is an event generator and should
# * be used to adjust the random number sequence.
# * The variable is_ok should be set to 0 if everything went smoothly,
# * or to some error code if it didnt.
# **************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_set_parallel(const IAEA_I32 *id, const IAEA_I32 *i_parallel,
#                        const IAEA_I32 *i_chunk, const IAEA_I32 *n_chunk,
#                        IAEA_I32 *is_ok);
#
# /**************************************************************************
# * setting the pointer to a user-specified record no. in the file
# *
# * record_num is the user-specified record number passed to the function.
# * id is the phase space file identifier.
# * The variable result should be set to 0 if everything went smoothly,
# * or to some error code if it didnt.
# **************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_set_record(const IAEA_I32 *id, const IAEA_I64 *record_num,
#                            IAEA_I32 *result);
#
# /**************************************************************************
# * check that the file size equals the value of checksum in the header
# *
# * id is the phase space file identifier.  If the size of the phase space
# * file is not equal to checksum, then result returns -1, otherwise result
# * is set to 0.
# **************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_check_file_size_byte_order(const IAEA_I32 *id, IAEA_I32 *result);

# /**************************************************************************
# * Get a particle
# *
# * Return the next particle from the sequence of particles from source
# * with Id id. Set n_stat to the number of statistically independent
# * events since the last call to this function (i.e. n_stat = 0, if
# * the particle resulted from the same incident electron, n_stat = 377
# * if there were 377 statistically independent events sinc the last particle
# * returned, etc.). If this information is not available,
# * simply set n_stat to 1 if the particle belongs to a new statistically
# * independent event. Set n_stat to -1, if a source with Id id does not
# * exist. Set n_stat to -2, if end of file of the phase space source reached
# **************************************************************************/

function get_particle(id::SourceId, n_stat=ref(IAEA_I32, 1))
    typ = ref(IAEA_I32)
    E = ref(IAEA_Float)
    wt = ref(IAEA_Float)
    x = ref(IAEA_Float)
    y = ref(IAEA_Float)
    z = ref(IAEA_Float)
    u = ref(IAEA_Float)
    v = ref(IAEA_Float)
    w = ref(IAEA_Float)
    n_extra_float, n_extra_int = get_extra_numbers(id)
    extra_floats = Vector{IAEA_Float}(n_extra_float)
    extra_ints = Vector{IAEA_I32}(n_extra_int)

    ccall(
    (:iaea_get_particle, LIB_IAEA),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_I32}, Ptr{IAEA_I32}, # id ,n_stat, type
    Ptr{IAEA_Float}, Ptr{IAEA_Float}, # E, wt
    Ptr{IAEA_Float}, Ptr{IAEA_Float}, Ptr{IAEA_Float}, # x, y, z
    Ptr{IAEA_Float}, Ptr{IAEA_Float}, Ptr{IAEA_Float}, # u, v, w
    Ptr{IAEA_Float}, Ptr{IAEA_I32}), # extra
    id, n_stat, typ,
    E, wt,
    x,y,z,
    u,v,w,
    extra_floats, extra_ints
    )
    return (value(typ),
     value(E), value(wt),
     value(x),value(y),value(z),
     value(u),value(v),value(w),
     extra_floats, extra_ints)
end
#
# /**************************************************************************
# * Write a particle
# * n_stat = 0 for a secondary particle
# * n_stat > 0 for an independent particle
# *
# * Write a particle to the source with Id id.
# * Set n_stat to -1, if ERROR (source with Id id does not exist).
# **************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_write_particle(const IAEA_I32 *id, IAEA_I32 *n_stat,
# const IAEA_I32 *type, /* particle type */
# const IAEA_Float *E,  /* kinetic energy in MeV */
# const IAEA_Float *wt, /* statistical weight */
# const IAEA_Float *x,
# const IAEA_Float *y,
# const IAEA_Float *z,  /* position in cartesian coordinates*/
# const IAEA_Float *u,
# const IAEA_Float *v,
# const IAEA_Float *w,  /* direction in cartesian coordinates*/
# const IAEA_Float *extra_floats,
# const IAEA_I32 *extra_ints);

function destroy_source(id::SourceId)
    result = ref(IAEA_I32)
    ccall(
    (:iaea_destroy_source, LIB_IAEA),
    Void, (Ptr{IAEA_I32}, Ptr{IAEA_I32}),
    id, result
    )
    value(result)
end

# /***************************************************************************
# * Print the current header associated to source id
# *
# * result is set to negative if phsp source does not exist.
# ****************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_print_header(const IAEA_I32 *source_ID, IAEA_I32 *result);
#
# /***************************************************************************
# * Copy header of the source_id to the header of the destiny_id
# ****************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_copy_header(const IAEA_I32 *source_ID, const IAEA_I32 *destiny_ID,
#                       IAEA_I32 *result);
#
# /***************************************************************************
# * Update header of the source_id
# ****************************************************************************/
# IAEA_EXTERN_C IAEA_EXPORT
# void iaea_update_header(const IAEA_I32 *source_ID, IAEA_I32 *result);
#
#
