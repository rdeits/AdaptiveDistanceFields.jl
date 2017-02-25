# AdaptiveDistanceFields

[![Build Status](https://travis-ci.org/rdeits/AdaptiveDistanceFields.jl.svg?branch=master)](https://travis-ci.org/rdeits/AdaptiveDistanceFields.jl)
[![codecov](https://codecov.io/gh/rdeits/AdaptiveDistanceFields.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/rdeits/AdaptiveDistanceFields.jl)

This package implements the adaptively sampled distance fields (ADFs) introduced by Frisken et al. [1]. An ADF represents an arbitrary signed distance function by locally approximating that function with a bilinear interpolation over a quadtree (in 2D) or a trilinear interpolation over an octree (in 3D). When the ADF is created, each cell in the tree is subdivided until the multilinear approximation is a sufficiently close match to the real signed distance function over that cell. 

The quadtree and octree data structures and the general adaptive sampling framework are provided by [RegionTrees.jl](https://github.com/rdeits/RegionTrees.jl). This package adds the ADF interpolation functions using [Interpolations.jl](https://github.com/tlycken/Interpolations.jl).

[1] Sarah F. Frisken, Ronald N. Perry, and Thouis R. Jones. "Adaptively Sampled Distance Fields: A General Representation of Shape for Computer Graphics". SIGGRAPH 2000. 

# Usage

Check out the `examples` folder for additional demonstrations. 

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

## Using meshes

The [EnhancedGJK.jl](https://github.com/rdeits/EnhancedGJK.jl) package provides tools for computing the signed distance between convex bodies. In particular, it provides the `ReferenceDistance.signed_distance` function to compute the distance from a mesh to a point using a slow but straightforward algorithm. That particular method is ideal for adaptive approximation:


```julia
julia> Pkg.add("EnhancedGJK")

julia> using MeshIO

julia> using FileIO

julia> using BenchmarkTools

julia> mesh = load(joinpath(Pkg.dir("EnhancedGJK"), "test", "meshes", "base_link.obj"))

HomogenousMesh(
    normals: 52xGeometryTypes.Normal{3,Float32},     vertices: 52xFixedSizeArrays.Point{3,Float32},     faces: 100xGeometryTypes.Face{3,UInt32,-1}, )


julia> adf = AdaptiveDistanceField(ReferenceDistance.signed_distance(mesh),
                                   SVector(-4., -4, -4), SVector(8., 8, 8),
                                   0.05, 0.05)
(::AdaptiveDistanceField) (generic function with 1 method)

julia> p = SVector(0.2, 0.1, 0.15)
3-element StaticArrays.SVector{3,Float64}:
 0.2
 0.1
 0.15

julia> @benchmark(ConvexMesh.signed_distance($mesh, $p))
BenchmarkTools.Trial:
  memory estimate:  1.94 KiB
  allocs estimate:  8
  --------------
  minimum time:     10.346 μs (0.00% GC)
  median time:      10.678 μs (0.00% GC)
  mean time:        11.914 μs (2.06% GC)
  maximum time:     2.510 ms (97.94% GC)
  --------------
  samples:          10000
  evals/sample:     1
  time tolerance:   5.00%
  memory tolerance: 1.00%

julia> @benchmark($adf($p))
BenchmarkTools.Trial:
  memory estimate:  64 bytes
  allocs estimate:  4
  --------------
  minimum time:     145.978 ns (0.00% GC)
  median time:      148.954 ns (0.00% GC)
  mean time:        161.464 ns (2.11% GC)
  maximum time:     1.786 μs (89.29% GC)
  --------------
  samples:          10000
  evals/sample:     832
  time tolerance:   5.00%
  memory tolerance: 1.00%
```
