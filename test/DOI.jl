using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "DOI test" begin
    @test_reference "references/DataCite.txt" generate(DOI(), "10.5281/zenodo.1147572")
    @test_reference "references/CrossRef.txt" generate(DOI(), "https://doi.org/10.1126/science.169.3946.635")
end