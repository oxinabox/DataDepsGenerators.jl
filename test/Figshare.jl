using DataDeps
using DataDepsGenerators
using Test
using MD5
using Suppressor
using ReferenceTests

@testset "Figshare test" begin

    @testset "Chile Activism" begin
        registration_code = generate(Figshare(), "https://figshare.com/articles/Youth_Activism_in_Chile_from_urban_educational_inequalities_to_experiences_of_living_together_and_solidarity/6504206")

        @testset "Integration Test" begin
            eval(Meta.parse(registration_code))
            @test length(collect(readdir(datadep"Youth Activism in Chile from urban educational inequalities to experiences of living together and solidarity"))) > 0
        end
        
        @test_reference "references/Figshare Chile Activism.txt" registration_code
    end

    @test_reference "references/Figshare from doi.txt" generate(Figshare(), "10.1371/journal.pbio.2001414")
end
