using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "DataDryadWeb test" begin
    @test_reference "references/DataDryad Ecology.txt" generate(DataDryadWeb(), "https://datadryad.org/resource/doi:10.5061/dryad.74699")
    
    #Checking files with multiple files available for download
    @test_reference "references/DataDryad Plasticity.txt" generate(DataDryadWeb(), "https://datadryad.org/resource/doi:10.5061/dryad.f9s4424")
    @test_reference "references/DataDryad Drought.txt" generate(DataDryadWeb(), "https://datadryad.org/resource/doi:10.5061/dryad.cc8834s")
end
