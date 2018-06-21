using Base.Test
using TestSetExtensions

tests = [
    "UCI",
    "GitHub",
    "DataDryad",
    "DataOneV1",
    "DataOneV2/KNB",
    "DataOneV2/TERN",
    "CKAN",
    "DataCite",
    "format_checksum"
]

for filename in tests
    @testset ExtendedTestSet "$filename" begin
        include(filename * ".jl")
    end
end
