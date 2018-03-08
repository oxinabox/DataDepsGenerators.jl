using Base.Test
using TestSetExtensions

tests = [
    "UCI",
    "GitHub",
    "DataDryad"    
]

for filename in tests
    @testset ExtendedTestSet "$filename" begin
        include(filename * ".jl")
    end
end
