# AdaptiveDistanceFields

[![Build Status](https://travis-ci.org/rdeits/AdaptiveDistanceFields.jl.svg?branch=master)](https://travis-ci.org/rdeits/AdaptiveDistanceFields.jl)
[![codecov](https://codecov.io/gh/rdeits/AdaptiveDistanceFields.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/rdeits/AdaptiveDistanceFields.jl)

This package implements the adaptively sampled distance fields (ADFs) introduced by Frisken et al. [1]. An ADF represents an arbitrary signed distance function by locally approximating that function with a bilinear interpolation over a quadtree (in 2D) or a trilinear interpolation over an octree (in 3D). When the ADF is created, each cell in the tree is subdivided until the multilinear approximation is a sufficiently close match to the real signed distance function over that cell. 

The quadtree and octree data structures and the general adaptive sampling framework are provided by [RegionTrees.jl](https://github.com/rdeits/RegionTrees.jl). This package adds the ADF interpolation functions and some helpers for creating signed distance functions from convex meshes.

[1] Sarah F. Frisken, Ronald N. Perry, and Thouis R. Jones. "Adaptively Sampled Distance Fields: A General Representation of Shape for Computer Graphics". SIGGRAPH 2000. 
