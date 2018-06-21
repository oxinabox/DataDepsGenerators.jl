using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "DataOneV1 test" begin
    # @testset "DataDryadWeb Ecology" begin
    #     registration_code = generate(DataDryadWeb(), "https://datadryad.org/resource/doi:10.5061/dryad.74699")

    #     @testset "Integration Test" begin
    #         eval(parse(registration_code))
    #         @test length(collect(readdir(datadep"Data from Ecology and genomics of an important crop wild relative as a prelude to agricultural innovation"))) > 0
    #     end
        
    #     @test_reference "references/DataDryad Ecology.txt" registration_code
    # end
    @test_reference "references/DataOneV1 Ecology.txt" generate(DataOneV1(), "https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.74699")
    
    #Checking files with multiple files available for download
    @test_reference "references/DataOneV1 Plasticity.txt" generate(DataOneV1(), "https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.f9s4424")
    @test_reference "references/DataOneV1 Drought.txt" generate(DataOneV1(), "https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.cc8834s")
end
