using Base.Test
using TestSetExtensions

tests = [
    "UCI",
    "GitHub",
    "DataDryad",
    "format_checksum"    
]

for filename in tests
    @testset ExtendedTestSet "$filename" begin
        include(filename * ".jl")
    end
end
