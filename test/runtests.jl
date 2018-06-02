using Base.Test
using TestSetExtensions

tests = [
    "UCI",
    "GitHub",
    "DataDryadWeb",
    "DataDryadAPI",
    # "DataOneV2/KNB",
    "DataOneV2/TERN",
    "format_checksum"
]

for filename in tests
    @testset ExtendedTestSet "$filename" begin
        include(filename * ".jl")
    end
end
