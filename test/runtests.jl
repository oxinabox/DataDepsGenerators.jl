using Test

tests = [
    "format_checksum",
    "citation_generation",
    "UCI",
    "GitHub",
    "DataDryad",
    "DataOneV1",
    "DataOneV2/KNB",
    "DataOneV2/TERN",
    "CKAN",
    "DataCite",
    "Figshare",
    "JSONLD/JSONLD",
    "combine",
]

@testset "DataDepGenerators" begin
    for filename in tests
        @testset "$filename" begin
            include(filename * ".jl")
        end
    end
end