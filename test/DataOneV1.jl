using DataDepsGenerators
using Test

using ReferenceTests

@testset "DataOneV1 test" begin
    @test_reference "references/DataOneV1 Ecology.txt" remove_cite_version(generate(DataOneV1(), "https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.74699"))
    
    #Checking files with multiple files available for download
    @test_reference "references/DataOneV1 Plasticity.txt"  remove_cite_version(generate(DataOneV1(), "https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.f9s4424"))
    @test_reference "references/DataOneV1 Drought.txt"  remove_cite_version(generate(DataOneV1(), "https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.cc8834s"))
end
