using Base.Test
using TestSetExtensions

tests = [
    "UCI",
    "GitHub",
    "DataDryadWeb",
    "DataDryadAPI",
<<<<<<< HEAD
    "DataOneV2/KNB",
    "DataOneV2/TERN",
=======
    "IntegrationTests",
>>>>>>> Add Integration Tests
    "format_checksum"
]

for filename in tests
    @testset ExtendedTestSet "$filename" begin
        include(filename * ".jl")
    end
end
