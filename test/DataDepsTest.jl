using DataDeps
using Base.Test
@testset "Testing DataDyrad DataDeps" begin
    include("references/DataDryad Drought.txt")
    include("references/DataDryad Plasticity.txt")

    @test length(collect(readdir(datadep"Data from Drought intensification drives turnover of structure and function in stream invertebrate communities"))) > 0
    @test length(collect(readdir(datadep"Data from Plasticity of plant defense and its evolutionary implications in wild populations of Boechera stricta"))) > 0
end

@testset "Testing GitHub DataDeps" begin
    include("references/538 college.txt")

    @test length(collect(readdir(datadep"College Majors"))) > 0
end

@testset "Testing BuzzFeed DataDeps" begin
    include("references/buzzfeed pres-camp.txt")

    @test length(collect(readdir(datadep"Presidential Campaign Contributions"))) > 0
end

@testset "Testing UCI DataDeps" begin
    include("references/UCI Forest Fires.txt")

    @test length(collect(readdir(datadep"Forest Fires Data Set (UCI ML Repository)"))) > 0
end