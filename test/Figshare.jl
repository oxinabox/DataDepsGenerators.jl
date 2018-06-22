using DataDeps
using DataDepsGenerators
using Base.Test
using MD5

using ReferenceTests

@testset "Figshare test" begin

    @testset "Figshare Gene Diversity" begin
        registration_code = generate(Figshare(), "https://figshare.com/articles/Youth_Activism_in_Chile_from_urban_educational_inequalities_to_experiences_of_living_together_and_solidarity/6504206")

        @testset "Integration Test" begin
            eval(parse(registration_code))
            @test length(collect(readdir(datadep"Youth Activism in Chile from urban educational inequalities to experiences of living together and solidarity"))) > 0
        end
        
        @test_reference "references/Figshare Chile Activism.txt" registration_code
    end

    @test_reference "references/Figshare Gene Diversity.txt" generate(Figshare(), "10.5281/zenodo.1194927")
end