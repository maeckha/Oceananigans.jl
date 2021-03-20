struct Buoyancy{M, G}
                   model :: M
    vertical_unit_vector :: G
end

struct VerticalDirection end

function Buoyancy(; model, vertical_unit_vector=VerticalDirection())
    ĝ = vertical_unit_vector
    ĝ isa VerticalDirection || length(ĝ) == 3 ||
        throw(ArgumentError("vertical_unit_vector must have length 3"))

    if !isa(ĝ, VerticalDirection)
        gx, gy, gz = ĝ

        gx^2 + gy^2 + gz^2 ≈ 1 ||
            throw(ArgumentError("vertical_unit_vector must be a unit vector with g[1]² + g[2]² + g[3]² = 1"))
    end

    return Buoyancy(model, ĝ)
end

@inline ĝ_x(buoyancy) = @inbounds buoyancy.vertical_unit_vector[1]
@inline ĝ_y(buoyancy) = @inbounds buoyancy.vertical_unit_vector[2]
@inline ĝ_z(buoyancy) = @inbounds buoyancy.vertical_unit_vector[3]

@inline ĝ_x(::Buoyancy{M, VerticalDirection}) where M = 0
@inline ĝ_y(::Buoyancy{M, VerticalDirection}) where M = 0
@inline ĝ_z(::Buoyancy{M, VerticalDirection}) where M = 1

#####
##### For convinience
#####

@inline required_tracers(bm::Buoyancy) = required_tracers(bm.model)

@inline get_temperature_and_salinity(bm::Buoyancy, C) = get_temperature_and_salinity(bm.model, C)

@inline ∂x_b(i, j, k, grid, b::Buoyancy, C) = ∂x_b(i, j, k, grid, b.model, C)
@inline ∂y_b(i, j, k, grid, b::Buoyancy, C) = ∂y_b(i, j, k, grid, b.model, C)
@inline ∂z_b(i, j, k, grid, b::Buoyancy, C) = ∂z_b(i, j, k, grid, b.model, C)

regularize_buoyancy(b) = b
regularize_buoyancy(b::AbstractBuoyancyModel) = Buoyancy(model=b)
