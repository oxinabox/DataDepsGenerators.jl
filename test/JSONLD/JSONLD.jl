using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "JSONLD test" begin
    @test_reference "../references/JSONLD_Web Kaggle.txt" generate(JSONLD_Web(), "https://zenodo.org/record/1287281")
    @test_reference "../references/JSONLD_DOI Figshare.txt" generate(JSONLD_DOI(), "10.1371/journal.pbio.2001414")
end
