struct SignedDistanceRefinery{F <: Function} <: AbstractRefinery
    signed_distance_func::F
    atol::Float64
    rtol::Float64
end

function needs_refinement(refinery::SignedDistanceRefinery, cell::Cell)
    minimum(cell.boundary.widths) > refinery.atol || return false

    for c in body_and_face_centers(cell.boundary)
        value_interp = evaluate(cell, c)
        value_true = refinery.signed_distance_func(c)
        if !isapprox(value_interp, value_true, rtol=refinery.rtol, atol=refinery.atol)
            return true
        end
    end
    return false
end

function refine_data(refinery::SignedDistanceRefinery, cell::Cell, indices)
    refine_data(refinery, child_boundary(cell, indices))
end

function refine_data(refinery::SignedDistanceRefinery, boundary::HyperRectangle)
    extrapolate(interpolate!(refinery.signed_distance_func.(vertices(boundary)),
                             BSpline(Linear())),
                             Line())
end
