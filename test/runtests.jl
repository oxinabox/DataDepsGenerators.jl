using Base.Test
using TestSetExtensions

tests = [
    "UCI",
    "GitHub",
    "DataDryadWeb",
    "DataDryadAPI",
    "DataOnev2/KNB",
    "format_checksum"
]

for filename in tests
    @testset ExtendedTestSet "$filename" begin
        include(filename * ".jl")
    end
end
