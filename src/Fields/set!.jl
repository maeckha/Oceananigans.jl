using CUDA
using KernelAbstractions: @kernel, @index
using Oceananigans.Architectures: device, GPU, AbstractCPUArchitecture, AbstractGPUArchitecture
using Oceananigans.Utils: work_layout

function set!(Φ::NamedTuple; kwargs...)
    for (fldname, value) in kwargs
        ϕ = getproperty(Φ, fldname)
        set!(ϕ, value)
    end
    return nothing
end

set!(u::AbstractField, v::Number) = parent(u) .= v

set!(u::AbstractField{X, Y, Z, A}, v::AbstractField{X, Y, Z, A}) where {X, Y, Z, A} =
    parent(u) .= parent(v)

# Niceties
const AbstractCPUField = AbstractField{X, Y, Z, <:AbstractCPUArchitecture} where {X, Y, Z}
const AbstractReducedCPUField = AbstractReducedField{X, Y, Z, <:AbstractCPUArchitecture} where {X, Y, Z}

"Set the CPU field `u` to the array `v`."
function set!(u::AbstractCPUField, v::Array)

    Sx, Sy, Sz = size(u)
    for k in 1:Sz, j in 1:Sy, i in 1:Sx
        u[i, j, k] = v[i, j, k]
    end

    return nothing
end

""" Returns an AbstractReducedField on the CPU. """
function similar_cpu_field(u::AbstractReducedField)
    FieldType = typeof(u).name.wrapper
    return FieldType(location(u), CPU(), u.grid; dims=u.dims)
end

""" Set the CPU field `u` data to the function `f(x, y, z)`. """
set!(u::AbstractCPUField, f::Function) = interior(u) .= f.(nodes(u; reshape=true)...)

#####
##### set! for fields on the GPU
#####

const AbstractGPUField = AbstractField{X, Y, Z, <:AbstractGPUArchitecture} where {X, Y, Z}
const AbstractReducedGPUField = AbstractReducedField{X, Y, Z, <:AbstractGPUArchitecture} where {X, Y, Z}

""" Returns a field on the CPU with `nothing` boundary conditions. """
function similar_cpu_field(u)
    FieldType = typeof(u).name.wrapper
    return FieldType(location(u), CPU(), u.grid, nothing)
end

""" Set the GPU field `u` to the array or function `v`. """
function set!(u::AbstractGPUField, v::Union{Array, Function})
    v_field = similar_cpu_field(u)
    set!(v_field, v)
    set!(u, v_field)
    return nothing
end

""" Set the GPU field `u` to the CuArray `v`. """
function set!(u::AbstractGPUField, v::CuArray)

    launch!(GPU(), u.grid, :xyz, _set_gpu!, u.data, v,
            include_right_boundaries=true, location=location(u))

    return nothing
end

@kernel function _set_gpu!(u, v)
    i, j, k = @index(Global, NTuple)
    @inbounds u[i, j, k] = v[i, j, k]
end

""" Set the CPU field `u` data to the GPU field data of `v`. """
set!(u::AbstractCPUField, v::AbstractGPUField) = u.data.parent .= Array(v.data.parent)

""" Set the GPU field `u` data to the CPU field data of `v`. """
set!(u::AbstractGPUField, v::AbstractCPUField) = copyto!(u.data.parent, v.data.parent)
