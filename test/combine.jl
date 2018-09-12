using DataDepsGenerators
using Test

using ReferenceTests

@testset "Combining test" begin
    @test_reference "references/Combining Ecology.txt" remove_cite_version(generate("10.5061/dryad.74699"))
    
    @test_reference "references/Combining Plasticity.txt" remove_cite_version(generate("https://datadryad.org/mn/object/http://dx.doi.org/10.5061/dryad.f9s4424"))

    @test_reference "references/Combining Gene Diversity.txt" remove_cite_version(generate("10.5281/zenodo.1194927"))

    @test_reference "references/Combining Stack Overflow.txt" generate("https://www.kaggle.com/stackoverflow/stack-overflow-2018-developer-survey")
    
    @test_reference "references/Combining Chile Activism.txt" generate("https://figshare.com/articles/Youth_Activism_in_Chile_from_urban_educational_inequalities_to_experiences_of_living_together_and_solidarity/6504206")
end
