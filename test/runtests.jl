using Base.Test

tests = [
    "UCI"
]

for filename in tests
    @testset "$filename" begin
        include(filename * ".jl")
    end
end
