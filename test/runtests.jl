using Ratios, Test
using FixedPointNumbers
using SaferIntegers

@testset "SimpleRatio" begin
    r = SimpleRatio(1,2)
    @test convert(Float64, r) == 0.5
    @test convert(Float32, r) == 0.5f0
    @test convert(BigFloat, r) == BigFloat(1)/2

    r2 = SimpleRatio(2,3)
    @test r*r2 == SimpleRatio(2,6) == SimpleRatio(1,3)
    @test r2*3 == 3*r2 == 2
    @test r*false == false*r == 0
    @test r/r2 == SimpleRatio(3,4)
    @test r/2 == SimpleRatio(1,4)
    @test 2/r == 4
    @test 4 == 2/r
    @test r+1 == 1+r == SimpleRatio(3,2)
    @test r-1 == SimpleRatio(-1,2)
    @test 1-r == r
    @test r+r2 == SimpleRatio(7,6)
    @test r-r2 == SimpleRatio(-1,6)
    @test r^2 == SimpleRatio(1,4)
    @test -r == SimpleRatio(-1,2)
    @test 0.2*r ≈ 0.1
    @test r == 0.5
    @test 0.5 == r

    @test_throws OverflowError -SimpleRatio(0x02,0x03)

    @test r + SimpleRatio(0x02,0x03) == SimpleRatio(7,6)

    @test SimpleRatio(11, 10) == 11//10
    @test 1//3 + SimpleRatio(1, 5) == 8//15

    @test isfinite(SimpleRatio(0,0)) == false
    @test isfinite(SimpleRatio(1,0)) == false
    @test isfinite(SimpleRatio(2,1)) == true

    @test SimpleRatio(5,3) * 0.035N0f8 == SimpleRatio{Int}(rationalize((5*0.035N0f8)/3))
    @test SimpleRatio(5,3) * 0.035N4f12 == SimpleRatio{Int}(rationalize((5*0.035N4f12)/3))
    @test SimpleRatio(5,3) * -0.03Q0f7 == SimpleRatio{Int}(rationalize((5.0*(-0.03Q0f7))/3))
    r = @inferred(SimpleRatio(0.75Q0f7))
    @test r == 3//4 && r isa SimpleRatio{Int16}

    @testset "SimpleRatio and SaferIntegers" begin
        @test_throws OverflowError Ratios.SimpleRatio{SafeInt64}(99980001, 99980001) + Ratios.SimpleRatio{SafeInt64}(999800010000, 99980002)
        @test -Ratios.SimpleRatio{SafeInt}(1,5) == Ratios.SimpleRatio{SafeInt}(-1,5)
        @test_throws OverflowError -Ratios.SimpleRatio{SafeUInt}(1,5) == Ratios.SimpleRatio{SafeInt}(-1,5)
        let a_den = 5, b_den = 255
            @test b_den % a_den == 0
            correct_numerator = b_den ÷ a_den + 1

            # The addition overflows and the sum is wrong
            T = UInt8
            ST = SaferIntegers.safeint(T)
            @test SimpleRatio{T}(1, a_den) + SimpleRatio{T}(1, b_den) == SimpleRatio{T}(correct_numerator, b_den)
            @test convert(Float64, SimpleRatio{T}(1, a_den) + SimpleRatio{T}(1, b_den) ) != convert(Float64, SimpleRatio{T}(correct_numerator, b_den))
            @test_throws OverflowError SimpleRatio{ST}(1, a_den) + SimpleRatio{ST}(1, b_den) == SimpleRatio{ST}(correct_numerator, b_den)

            # The addition works, but checking equality overflows
            T = UInt16
            ST = SaferIntegers.safeint(T)
            @test SimpleRatio{T}(1, a_den) + SimpleRatio{T}(1, b_den) == SimpleRatio{T}(correct_numerator, b_den)
            @test convert(Float64, SimpleRatio{T}(1, a_den) + SimpleRatio{T}(1, b_den) ) == convert(Float64, SimpleRatio{T}(correct_numerator, b_den))
            @test_throws OverflowError SimpleRatio{ST}(1, a_den) + SimpleRatio{ST}(1, b_den) == SimpleRatio{ST}(correct_numerator, b_den)

            # No overflow, everything works
            T = UInt32
            ST = SaferIntegers.safeint(T)
            @test SimpleRatio{T}(1, a_den) + SimpleRatio{T}(1, b_den) == SimpleRatio{T}(correct_numerator, b_den)
            @test convert(Float64, SimpleRatio{T}(1, a_den) + SimpleRatio{T}(1, b_den) ) == convert(Float64, SimpleRatio{T}(correct_numerator, b_den))
            @test SimpleRatio{ST}(1, a_den) + SimpleRatio{ST}(1, b_den) == SimpleRatio{ST}(correct_numerator, b_den)
        end
    end
end
