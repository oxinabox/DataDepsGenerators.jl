using DataDepsGenerators
using Base.Test

using ReferenceTests

@test_reference "references/UCI Air+Quality.txt" generate(UCI(), "Air+Quality")
@test_reference "references/UCI auto mpg.txt" generate(UCI(), "auto+mpg")
@test_reference "references/UCI banking marketting.txt" generate(UCI(), "bank+marketing")
@test_reference "references/UCI BHP.txt" generate(UCI(), "Burst+Header+Packet+%28BHP%29+flooding+attack+on+Optical+Burst+Switching+%28OBS%29+Network")
# ^ With names like that, the user is really going to want to edit the automatically determined short name into something shorted


@test_reference "references/UCI Adult.txt" generate(UCI(), "Adult")

@testset "ForestFires" begin

    registration_block = generate(UCI(), "Forest+Fires")


    @test contains(registration_block, "A Data Mining Approach to Predict Forest Fires using Meteorological Data") # must get the citation info

    # All the above tests in this section (and more) are covered by the final check below
    # But more specific tests let us know which bits are broken
    @test_reference "references/UCI Forest Fires.txt" registration_block
end
