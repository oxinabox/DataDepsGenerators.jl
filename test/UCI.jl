using DataDeps
using DataDepsGenerators
using Test
using ReferenceTests

@testset "UCI Air Quality" begin
    registration_code = generate(UCI(), "Air+Quality")

    @testset "Integration Test" begin
        eval(Meta.parse(registration_code))
        @test length(collect(readdir(datadep"Air Quality Data Set (UCI ML Repository)"))) > 0
    end

    @test_reference "references/UCI Air+Quality.txt" registration_code
end

@test_reference "references/UCI auto mpg.txt" generate(UCI(), "https://archive.ics.uci.edu/ml/datasets/auto+mpg")
@test_reference "references/UCI banking marketting.txt" generate(UCI(), "bank+marketing")
@test_reference "references/UCI BHP.txt" generate(UCI(), "Burst+Header+Packet+%28BHP%29+flooding+attack+on+Optical+Burst+Switching+%28OBS%29+Network", "Burst Header Packet (UCI)")

@test_reference "references/UCI Adult.txt" generate(UCI(), "Adult")

@testset "ForestFires" begin
    registration_block = generate(UCI(), "Forest+Fires")

    @test occursin("A Data Mining Approach to Predict Forest Fires using Meteorological Data", registration_block) # must get the citation info

    # All the above tests in this section (and more) are covered by the final check below
    # But more specific tests let us know which bits are broken
    @test_reference "references/UCI Forest Fires.txt" registration_block
end
