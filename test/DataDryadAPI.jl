using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "DataDryadAPI test" begin
    @test_reference "references/DataDryadAPI Ecology.txt" generate(DataDryadAPI(), "https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.74699")
    
    #Checking files with multiple files available for download
    @test_reference "references/DataDryadAPI Plasticity.txt" generate(DataDryadAPI(), "https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.f9s4424")
    @test_reference "references/DataDryadAPI Drought.txt" generate(DataDryadAPI(), "https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.cc8834s")
end
