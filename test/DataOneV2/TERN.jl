using DataDepsGenerators
using Test

using ReferenceTests

@testset "TERN test" begin
    @test_reference "../references/TERN/Influenza A.txt" generate(TERN(), "https://dataone.tern.org.au/mn/v2/object/aekos.org.au/collection/nsw.gov.au/nsw_atlas/vis_flora_module/KAHDRAIN.20150515")
end