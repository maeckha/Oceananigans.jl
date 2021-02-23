using Printf
using Revise
using Oceananigans
using Oceananigans.Fields
using Oceananigans.OutputWriters
using Oceananigans.Advection
using Oceananigans.Utils

#++++ Model set-up
Nx = Ny = Nz = 8
Lx = Ly = Lz = 1
N² = 1e-4 # s⁻²

grid = RegularRectilinearGrid(size=(Nx, Ny, Nz), extent=(Lx, Ly, Lz), topology=(Periodic, Periodic, Periodic))

model = IncompressibleModel(
                   grid = grid,
              advection = UpwindBiasedFifthOrder(),
            timestepper = :RungeKutta3,
                closure = IsotropicDiffusivity(ν=1e-4, κ=1e-4),
               coriolis = FPlane(f=1e-4),
                tracers = (:b,), # P for Plankton
               buoyancy = BuoyancyTracer(),
)
println()
println(model)
println()
#-----

#++++ Initial conditions
u0(x, y, z) = y<Ly/2 ? 0.5 : 0.7
v0(x, y, z) = 0.2
w0(x, y, z) = 0.2*y

set!(model, u=u0, v=v0, w=w0)
#-----


#++++
struct WindowedSpatialAverage{F, S, D}
          field :: F
   field_slicer :: S
           dims :: D
end
WindowedSpatialAverage(field; dims, field_slicer=FieldSlicer()) = WindowedSpatialAverage(field, field_slicer, dims)

using Oceananigans.OutputWriters: slice_parent
using Statistics: mean
function (wsa::WindowedSpatialAverage)(model)
    compute!(wsa.field)
    window = slice_parent(wsa.field_slicer, wsa.field)
    return dropdims(mean(window, dims=wsa.dims), dims=wsa.dims)
end

using NCDatasets: defVar
using Oceananigans.Fields: reduced_location
import Oceananigans.OutputWriters: xdim, ydim, zdim, define_output_variable!

function define_output_variable!(dataset, 
                                 wtsa::Union{WindowedSpatialAverage, WindowedTimeAverage{<:WindowedSpatialAverage}}, 
                                 name, array_type, compression, attributes, dimensions)
    if wtsa isa WindowedSpatialAverage
        wsa = wtsa
    elseif wtsa isa WindowedTimeAverage
        wsa = wtsa.operand
    else
        throw("Wrong type for windowed averaged")
    end
    LX, LY, LZ = reduced_location(location(wsa.field), dims=wsa.dims)
    output_dims = tuple(xdim(LX)..., ydim(LY)..., zdim(LZ)...)
    defVar(dataset, name, eltype(array_type), (output_dims..., "time"),
           compression=compression, attrib=attributes)
    return nothing
end
#----


#++++
using Oceananigans.Grids
u, v, w = model.velocities
slicer = FieldSlicer(j=Ny÷2+1:Ny)

Uw = WindowedSpatialAverage(u; dims=2, field_slicer=slicer)
U2w = WindowedSpatialAverage(ComputedField(u^2); dims=(1, 2), field_slicer=slicer)
#----



progress(sim) = @printf("Iteration: %d, time: %s, Δt: %s\n",
                        sim.model.clock.iteration,
                        prettytime(sim.model.clock.time),
                        prettytime(sim.Δt))

simulation = Simulation(model, Δt=1second, iteration_interval=5, progress=progress, stop_iteration=10,)

wout = (;  Uw, U2w)
simulation.output_writers[:simple_output] = NetCDFOutputWriter(model, wout, 
                                                               schedule = TimeInterval(10seconds),
                                                               filepath = "windowed_avg.nc", mode = "c")

run!(simulation)
