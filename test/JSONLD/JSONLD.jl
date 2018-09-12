using DataDepsGenerators
using Test

using ReferenceTests

@testset "JSON-LD Web" begin
    @test_reference "../references/JSONLD_Web Kaggle.txt" generate(JSONLD_Web(), "https://www.kaggle.com/stackoverflow/stack-overflow-2018-developer-survey")
    @test_reference "../references/JSONLD_Web Zenodo.txt" generate(JSONLD_Web(), "https://zenodo.org/record/1287281")
    @test_reference "../references/JSONLD_Web Dataverse.txt" generate(JSONLD_Web(), "https://dataverse.harvard.edu/dataset.xhtml?persistentId=hdl:1902.1/15580")
    
    @test_reference "../references/JSONLD_Web Figshare.txt" generate(JSONLD_Web(), "https://figshare.com/articles/_shows_examples_of_coordinated_and_uncoordinated_motion_for_dangerous_and_non_dangerous_crowd_behavior_/186003")
end
    
@testset "JSON-LD DOI" begin
    @test_reference "../references/JSONLD_DOI Figshare.txt" generate(JSONLD_DOI(), "10.1371/journal.pbio.2001414")
    @test_reference "../references/JSONLD_DOI PBIO.txt" generate(JSONLD_DOI(), "https://data.datacite.org/10.1371/journal.pbio.2001414")

    @test_reference "../references/JSONLD_DOI Figshare external.txt" generate(JSONLD_DOI(), "http://doi.org/10.6084/m9.figshare.5557801.v1")
end
