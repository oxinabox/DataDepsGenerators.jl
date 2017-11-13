using Revise
using DataDepsGenerators
using Base.Test

using ReferenceTests

@test_reference "references/UCI Air+Quality.txt" generate(UCI(), "Air+Quality")
@test_reference "references/UCI auto mpg.txt" generate(UCI(), "auto+mpg")
