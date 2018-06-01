using Base.Test
using TestSetExtensions

tests = [
    "UCI",
    "GitHub",
    "DataDryadWeb",
    "DataDryadAPI",
    "format_checksum",
    "IntegrationTests"    
]

for filename in tests
    @testset ExtendedTestSet "$filename" begin
        include(filename * ".jl")
    end
end
