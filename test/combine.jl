using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "Combining test" begin
    @test_reference "references/Combining Ecology.txt" remove_cite_version(generate("10.5061/dryad.74699"))
    
    @test_reference "references/Combining Plasticity.txt" remove_cite_version(generate("https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.f9s4424"))

    @test_reference "references/Combining Gene Diversity.txt" remove_cite_version(generate("10.5281/zenodo.1194927"))
end
