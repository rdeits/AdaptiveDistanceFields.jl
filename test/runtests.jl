import ForwardDiff  # Needs to be first due to https://github.com/JuliaMath/Interpolations.jl/issues/207
using AdaptiveDistanceFields
using Base.Test
using StaticArrays: SVector

@testset "coarse" begin
    rtol = 0.05
    atol = 0.1
    s = x -> sqrt(sum((x - SVector(1, 2)).^2))
    adf = AdaptiveDistanceField(s, SVector(-1., -1), SVector(5., 5), rtol, atol)

    for x in linspace(-1, 4)
        for y in linspace(-1, 4)
            @test isapprox(adf(SVector(x, y)), s(SVector(x, y)), atol=atol, rtol=rtol)
        end
    end
end

@testset "fine" begin
    rtol = 0.001
    atol = 0.001
    s = x -> sqrt(sum((x - SVector(-2, -1)).^2))
    adf = AdaptiveDistanceField(s, SVector(-5., -5), SVector(10., 10), rtol, atol)

    for x in linspace(-5, 5)
        for y in linspace(-5, 5)
            @test isapprox(adf(SVector(x, y)), s(SVector(x, y)), atol=0.005, rtol=0.005)
        end
    end
end

@testset "extrapolation" begin
    s = x -> sqrt(sum((x - SVector(-2, -1)).^2))
    adf = AdaptiveDistanceField(s, SVector(-5., -5), SVector(10., 10))

    @test isapprox(ForwardDiff.derivative(x -> adf(SVector(x, -1)), 100), 1, atol=1e-2, rtol=1e-2)
    @test isapprox(ForwardDiff.derivative(x -> adf(SVector(x, -1)), -100), -1, atol=1e-2, rtol=1e-2)
    @test isapprox(ForwardDiff.derivative(y -> adf(SVector(-2, y)), 100), 1, atol=1e-2, rtol=1e-2)
    @test isapprox(ForwardDiff.derivative(y -> adf(SVector(-2, y)), -100), -1, atol=1e-2, rtol=1e-2)
end
