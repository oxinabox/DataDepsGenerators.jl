using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "DataDryad API test" begin
    @test_reference "references/DataDryad Ecology.txt" generate(DataDryad(), "https://datadryad.org/resource/doi:10.5061/dryad.74699")
end
