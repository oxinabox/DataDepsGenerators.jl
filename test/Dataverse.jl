using DataDepsGenerators
using Base.Test
using MD5

using ReferenceTests

@testset "Dataverse test" begin
    @test_reference "references/Dataverse Example.txt" generate(Dataverse(), "10.7910/DVN/XK9DL2")
end