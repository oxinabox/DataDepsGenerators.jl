using DataDepsGenerators
using Test

using ReferenceTests

@testset "KNB test" begin
    @test_reference "../references/KNB/KnowledgeNetworkforBiocomplexity Forage Fish.txt" generate(KnowledgeNetworkforBiocomplexity(), "https://knb.ecoinformatics.org/knb/d1/mn/v2/object/doi:10.5063/F1T43R7N")
end
