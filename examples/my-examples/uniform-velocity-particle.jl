using Oceananigans
using CairoMakie
using LazyGrids
# using UnicodePlots


grid = RegularRectilinearGrid(size=(128, 128), x=(-5, 5), y=(-5, 5),
topology=(Periodic, Periodic, Flat))
model = NonhydrostaticModel(grid=grid, tracers=:c, buoyancy=nothing)

initial_c(x, y, z) = exp.(-x.^2 - y.^2)
set!(model, u=1, c=initial_c)

xs =  LinRange(-5, 5, 128)
ys =  LinRange(-5, 5, 128)

global i = 400

while i in 700   

    simulation = Simulation(model, Δt=1e-2, stop_iteration = i)
    run!(simulation)


    fig = Figure(resolution=(700, 450), fontsize=18, font="sans")
    ax = fig[1, 1] = Axis(fig, xlabel="x", ylabel="y")
    cMatrixTrimmed = interior(model.tracers.c)[:, :, 1]'
    CairoMakie.heatmap!(xs, ys, cMatrixTrimmed, colormap = :deep)
    
    fig

    i += 100

end