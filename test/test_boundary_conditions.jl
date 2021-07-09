using Oceananigans.BoundaryConditions: PBC, ZFBC, OBC, ContinuousBoundaryFunction, DiscreteBoundaryFunction, regularize_field_boundary_conditions
using Oceananigans.Fields: Face, Center

simple_bc(ξ, η, t) = exp(ξ) * cos(η) * sin(t)

function can_instantiate_boundary_condition(bc, C, FT=Float64, ArrayType=Array)
    success = try
        bc(C, FT, ArrayType)
        true
    catch
        false
    end
    return success
end
        
@testset "Boundary conditions" begin
    @info "Testing boundary conditions..."

    @testset "Boundary condition instantiation" begin
        @info "  Testing boundary condition instantiation..."

        for C in (Value, Gradient, Flux)
            @test can_instantiate_boundary_condition(integer_bc, C)
            @test can_instantiate_boundary_condition(irrational_bc, C)
            @test can_instantiate_boundary_condition(simple_function_bc, C)
            @test can_instantiate_boundary_condition(parameterized_function_bc, C)
            @test can_instantiate_boundary_condition(field_dependent_function_bc, C)
            @test can_instantiate_boundary_condition(discrete_function_bc, C)
            @test can_instantiate_boundary_condition(parameterized_discrete_function_bc, C)

            for FT in float_types
                @test can_instantiate_boundary_condition(float_bc, C, FT)
                @test can_instantiate_boundary_condition(parameterized_field_dependent_function_bc, C, FT)

                for arch in archs
                    ArrayType = array_type(arch)
                    @test can_instantiate_boundary_condition(array_bc, C, FT, ArrayType)
                end
            end
        end
    end

    @testset "Field and coordinate boundary conditions" begin
        @info "  Testing field and coordinate boundary conditions..."

        # Triply periodic
        ppp_topology = (Periodic, Periodic, Periodic)
        ppp_grid = RegularRectilinearGrid(size=(1, 1, 1), extent=(1, 1, 1), topology=ppp_topology)

        default_bcs = FieldBoundaryConditions()

        u_bcs = regularize_field_boundary_conditions(default_bcs, ppp_grid, :u)
        v_bcs = regularize_field_boundary_conditions(default_bcs, ppp_grid, :v)
        w_bcs = regularize_field_boundary_conditions(default_bcs, ppp_grid, :w)
        T_bcs = regularize_field_boundary_conditions(default_bcs, ppp_grid, :T)

        @test u_bcs isa FieldBoundaryConditions
        @test u_bcs.x.left  isa PBC
        @test u_bcs.x.right isa PBC
        @test u_bcs.y.left  isa PBC
        @test u_bcs.y.right isa PBC
        @test u_bcs.z.left  isa PBC
        @test u_bcs.z.right isa PBC

        @test v_bcs isa FieldBoundaryConditions
        @test v_bcs.x.left  isa PBC
        @test v_bcs.x.right isa PBC
        @test v_bcs.y.left  isa PBC
        @test v_bcs.y.right isa PBC
        @test v_bcs.z.left  isa PBC
        @test v_bcs.z.right isa PBC

        @test w_bcs isa FieldBoundaryConditions
        @test w_bcs.x.left  isa PBC
        @test w_bcs.x.right isa PBC
        @test w_bcs.y.left  isa PBC
        @test w_bcs.y.right isa PBC
        @test w_bcs.z.left  isa PBC
        @test w_bcs.z.right isa PBC

        @test T_bcs isa FieldBoundaryConditions
        @test T_bcs.x.left  isa PBC
        @test T_bcs.x.right isa PBC
        @test T_bcs.y.left  isa PBC
        @test T_bcs.y.right isa PBC
        @test T_bcs.z.left  isa PBC
        @test T_bcs.z.right isa PBC

        # Doubly periodic. Engineers call this a "Channel geometry".
        ppb_topology = (Periodic, Periodic, Bounded)
        ppb_grid = RegularRectilinearGrid(size=(1, 1, 1), extent=(1, 1, 1), topology=ppb_topology)

        u_bcs = regularize_field_boundary_conditions(default_bcs, ppb_grid, :u)
        v_bcs = regularize_field_boundary_conditions(default_bcs, ppb_grid, :v)
        w_bcs = regularize_field_boundary_conditions(default_bcs, ppb_grid, :w)
        T_bcs = regularize_field_boundary_conditions(default_bcs, ppb_grid, :T)

        @test u_bcs isa FieldBoundaryConditions
        @test u_bcs.x.left  isa PBC
        @test u_bcs.x.right isa PBC
        @test u_bcs.y.left  isa PBC
        @test u_bcs.y.right isa PBC
        @test u_bcs.z.left  isa ZFBC
        @test u_bcs.z.right isa ZFBC

        @test v_bcs isa FieldBoundaryConditions
        @test v_bcs.x.left  isa PBC
        @test v_bcs.x.right isa PBC
        @test v_bcs.y.left  isa PBC
        @test v_bcs.y.right isa PBC
        @test v_bcs.z.left  isa ZFBC
        @test v_bcs.z.right isa ZFBC

        @test w_bcs isa FieldBoundaryConditions
        @test w_bcs.x.left  isa PBC
        @test w_bcs.x.right isa PBC
        @test w_bcs.y.left  isa PBC
        @test w_bcs.y.right isa PBC
        @test w_bcs.z.left  isa OBC
        @test w_bcs.z.right isa OBC

        @test T_bcs isa FieldBoundaryConditions
        @test T_bcs.x.left  isa PBC
        @test T_bcs.x.right isa PBC
        @test T_bcs.y.left  isa PBC
        @test T_bcs.y.right isa PBC
        @test T_bcs.z.left  isa ZFBC
        @test T_bcs.z.right isa ZFBC

        # Singly periodic. Oceanographers call this a "Channel", engineers call it a "Pipe"
        pbb_topology = (Periodic, Bounded, Bounded)
        pbb_grid = RegularRectilinearGrid(size=(1, 1, 1), extent=(1, 1, 1), topology=pbb_topology)

        u_bcs = regularize_field_boundary_conditions(default_bcs, pbb_grid, :u)
        v_bcs = regularize_field_boundary_conditions(default_bcs, pbb_grid, :v)
        w_bcs = regularize_field_boundary_conditions(default_bcs, pbb_grid, :w)
        T_bcs = regularize_field_boundary_conditions(default_bcs, pbb_grid, :T)

        @test u_bcs isa FieldBoundaryConditions
        @test u_bcs.x.left  isa PBC
        @test u_bcs.x.right isa PBC
        @test u_bcs.y.left  isa ZFBC
        @test u_bcs.y.right isa ZFBC
        @test u_bcs.z.left  isa ZFBC
        @test u_bcs.z.right isa ZFBC

        @test v_bcs isa FieldBoundaryConditions
        @test v_bcs.x.left  isa PBC
        @test v_bcs.x.right isa PBC
        @test v_bcs.y.left  isa OBC
        @test v_bcs.y.right isa OBC
        @test v_bcs.z.left  isa ZFBC
        @test v_bcs.z.right isa ZFBC

        @test w_bcs isa FieldBoundaryConditions
        @test w_bcs.x.left  isa PBC
        @test w_bcs.x.right isa PBC
        @test w_bcs.y.left  isa ZFBC
        @test w_bcs.y.right isa ZFBC
        @test w_bcs.z.left  isa OBC
        @test w_bcs.z.right isa OBC

        @test T_bcs isa FieldBoundaryConditions
        @test T_bcs.x.left  isa PBC
        @test T_bcs.x.right isa PBC
        @test T_bcs.y.left  isa ZFBC
        @test T_bcs.y.right isa ZFBC
        @test T_bcs.z.left  isa ZFBC
        @test T_bcs.z.right isa ZFBC

        # Triply bounded. Oceanographers call this a "Basin", engineers call it a "Box"
        bbb_topology = (Bounded, Bounded, Bounded)
        bbb_grid = RegularRectilinearGrid(size=(1, 1, 1), extent=(1, 1, 1), topology=bbb_topology)

        u_bcs = regularize_field_boundary_conditions(default_bcs, bbb_grid, :u)
        v_bcs = regularize_field_boundary_conditions(default_bcs, bbb_grid, :v)
        w_bcs = regularize_field_boundary_conditions(default_bcs, bbb_grid, :w)
        T_bcs = regularize_field_boundary_conditions(default_bcs, bbb_grid, :T)

        @test u_bcs isa FieldBoundaryConditions
        @test u_bcs.x.left  isa OBC
        @test u_bcs.x.right isa OBC
        @test u_bcs.y.left  isa ZFBC
        @test u_bcs.y.right isa ZFBC
        @test u_bcs.z.left  isa ZFBC
        @test u_bcs.z.right isa ZFBC

        @test v_bcs isa FieldBoundaryConditions
        @test v_bcs.x.left  isa ZFBC
        @test v_bcs.x.right isa ZFBC
        @test v_bcs.y.left  isa OBC
        @test v_bcs.y.right isa OBC
        @test v_bcs.z.left  isa ZFBC
        @test v_bcs.z.right isa ZFBC

        @test w_bcs isa FieldBoundaryConditions
        @test w_bcs.x.left  isa ZFBC
        @test w_bcs.x.right isa ZFBC
        @test w_bcs.y.left  isa ZFBC
        @test w_bcs.y.right isa ZFBC
        @test w_bcs.z.left  isa OBC
        @test w_bcs.z.right isa OBC

        @test T_bcs isa FieldBoundaryConditions
        @test T_bcs.x.left  isa ZFBC
        @test T_bcs.x.right isa ZFBC
        @test T_bcs.y.left  isa ZFBC
        @test T_bcs.y.right isa ZFBC
        @test T_bcs.z.left  isa ZFBC
        @test T_bcs.z.right isa ZFBC

        grid = bbb_grid
        
        T_bcs = AuxiliaryFieldBoundaryConditions(grid, (Center, Center, Center),
                                                   east = ValueBoundaryCondition(simple_bc),
                                                   west = ValueBoundaryCondition(simple_bc),
                                                 bottom = ValueBoundaryCondition(simple_bc),
                                                    top = ValueBoundaryCondition(simple_bc),
                                                  north = ValueBoundaryCondition(simple_bc),
                                                  south = ValueBoundaryCondition(simple_bc))

        @test T_bcs.east.condition === simple_bc
        @test T_bcs.west.condition === simple_bc
        @test T_bcs.north.condition === simple_bc
        @test T_bcs.south.condition === simple_bc
        @test T_bcs.top.condition === simple_bc
        @test T_bcs.bottom.condition === simple_bc

        one_bc = BoundaryCondition(Value, 1.0)

        T_bcs = FieldBoundaryConditions(   east = one_bc,
                                           west = one_bc,
                                         bottom = one_bc,
                                            top = one_bc,
                                          north = one_bc,
                                          south = one_bc)

        T_bcs = regularize_field_boundary_conditions(T_bcs, grid, :T)

        @test T_bcs.east   === one_bc
        @test T_bcs.west   === one_bc
        @test T_bcs.north  === one_bc
        @test T_bcs.south  === one_bc
        @test T_bcs.top    === one_bc
        @test T_bcs.bottom === one_bc
    end
end
