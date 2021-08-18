
using Oceananigans
using CairoMakie
# using LazyGrids
# using UnicodePlots


grid = RegularRectilinearGrid(size=(128, 128), x=(-5, 5), y=(-5, 5),
topology=(Periodic, Periodic, Flat))
model = NonhydrostaticModel(grid=grid, tracers=:c, buoyancy=nothing)

initial_c(x, y, z) = exp.(-x.^2 - y.^2)
set!(model, u=1, c=initial_c)

xs =  LinRange(-5, 5, 128)
ys =  LinRange(-5, 5, 128)

#  i = 1

# while i <= 3   

    
#     i += 1
    
# end
simulation = Simulation(model, Δt=1e-2, stop_iteration = 10)
run!(simulation)

# function plot_tracer(simulation)
#     c = simulation.model.tracers.c
#     fig = Figure(resolution=(700, 450), fontsize=18, font="sans")
#     ax = fig[1, 1] = Axis(fig, xlabel="x", ylabel="y")
#     cMatrixTrimmed = interior(model.tracers.c)[:, :, 1]'
#     CairoMakie.heatmap!(ax, xs, ys, cMatrixTrimmed, colormap = :deep)
#     display(fig)
# end

#simulation.callbacks[:plotter] = Callback(plot_tracer, schedule=IterationInterval(10))
    



    #fig = Figure(resolution=(700, 450), fontsize=18, font="sans")
    #ax = fig[1, 1] = Axis(fig, xlabel="x", ylabel="y")
    #cMatrixTrimmed = interior(model.tracers.c)[:, :, 1]'
    #CairoMakie.heatmap!(xs, ys, cMatrixTrimmed, colormap = :deep)
    
    #fig


# 0:130 auf 0:130 Datensatz wird auf 1:128 auf 1:128 getrimmt
# matrixTrimmed = model.tracers.c.data[1:128,1:128, 1]
#CairoMakie.heatmap(interior(model.tracers.c)[:, :, 1]')
# returns a view of f that excludes halo points


# (xx, yy) = ndgrid_array(xs, ys)

# us = [-x for x in xs]
# vs = [2y for y in ys]
# u2(x, y) = -x
# v2(x, y) = 2y

# # wird jetzt durch model.tracers.c.data ersetzt
# # zz = exp.(-xx.^2 - yy.^2)


# vel1  =-xx
# vel2 = 2*yy

# xsToPlot = xs[begin:2:end]

# #xsToPlot1 = xs[1:3:128]
# ysToPlot = ys[begin:2:end]
# #ysToPlot1 = ys[1:3:128]
# #(xx, yy) = ndgrid_array(xsToPlot, ysToPlot)
# #a[(1:length(a)) .% 3 .!= 0]

# u = ones(2)
# v = ones(2)

# arrows(xsToPlot, ysToPlot, interior(model.tracers.c), v, arrowsize=5, lengthscale=0.3,
# normalize = false)