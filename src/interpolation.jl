@generated function evaluate(itp::AbstractInterpolation, point::SVector{N}) where N
    Expr(:call, :itp, [:(point[$i]) for i in 1:N]...)
end

function evaluate(itp::AbstractInterpolation, point::AbstractArray)
    itp(point...)
end

function evaluate(cell::Cell{D}, point::AbstractArray) where {D <: AbstractInterpolation}
    leaf = findleaf(cell, point)
    evaluate(leaf.data, leaf.boundary, point)
end

function evaluate(interp::AbstractInterpolation, boundary::HyperRectangle, point::AbstractArray)
    coords = (point - boundary.origin) ./ boundary.widths .+ 1
    evaluate(interp, coords)
end

function gradient(cell::Cell{D}, point::AbstractArray) where {D <: AbstractInterpolation}
    leaf = findleaf(cell, point)
    gradient(leaf.data, leaf.boundary, point)
end

function gradient(interp::AbstractInterpolation, boundary::HyperRectangle, point::AbstractArray)
    coords = (point - boundary.origin) ./ boundary.widths .+ 1
    gradient(interp, coords) ./ boundary.widths
end

function gradient(itp::AbstractInterpolation, point::AbstractArray)
    gradient(itp, point...)
end
