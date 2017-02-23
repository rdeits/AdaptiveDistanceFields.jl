# AdaptiveDistanceFields

[![Build Status](https://travis-ci.org/rdeits/AdaptiveDistanceFields.jl.svg?branch=master)](https://travis-ci.org/rdeits/AdaptiveDistanceFields.jl)
[![codecov](https://codecov.io/gh/rdeits/AdaptiveDistanceFields.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/rdeits/AdaptiveDistanceFields.jl)

This package implements the adaptively sampled distance fields (ADFs) introduced by Frisken et al. [1]. An ADF represents an arbitrary signed distance function by locally approximating that function with a bilinear interpolation over a quadtree (in 2D) or a trilinear interpolation over an octree (in 3D). When the ADF is created, each cell in the tree is subdivided until the multilinear approximation is a sufficiently close match to the real signed distance function over that cell. 

The quadtree and octree data structures and the general adaptive sampling framework are provided by [RegionTrees.jl](https://github.com/rdeits/RegionTrees.jl). This package adds the ADF interpolation functions and some helpers for creating signed distance functions from convex meshes.

[1] Sarah F. Frisken, Ronald N. Perry, and Thouis R. Jones. "Adaptively Sampled Distance Fields: A General Representation of Shape for Computer Graphics". SIGGRAPH 2000. 

# Usage

To construct the adaptively sampled distance field, you need to at least provide the true signed distance function (typically one which is very expensive to compute) and a range over which to approximate it:

```julia
using AdaptiveDistanceFields
using StaticArrays

# Define our true signed distance function
true_signed_distance(x) = norm(x - SVector(0, 0))

# Approximate the signed distance function over the 
# range [-1, 1] in x and y:
origin = SVector(-1, -1)
widths = SVector(2, 2)
adf = AdaptiveDistanceField(true_signed_distance, origin, widths)

# Now we can call the adaptive distance field instead 
# of the original function
adf(SVector(0.6, 0.75))
```

The accuracy of the approximation can be controlled with the `atol` and `rtol` parameters, which set absolute and relative distance error tolerance, respectively:

```julia
rtol = 1e-2
atol = 1e-2
adf = AdaptiveDistanceField(true_signed_distance, origin, widths, rtol, atol)
```

The meanings of `rtol` and `atol` are equivalent to those used by the built-in `isapprox()`: a cell is divided if `norm(true - approximate) <= atol + rtol*max(norm(true), norm(approximate))`, evaluated at the center of the cell and and the center of each of its faces. 
