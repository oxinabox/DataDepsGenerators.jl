using DataDeps
using DataDepsGenerators
using Base.Test

using ReferenceTests

# @testset "CKAN Demo test" begin
#     registration_code = generate(CKAN(), "https://demo.ckan.org/dataset/gold-prices")

#     @testset "Integration Test" begin
#         eval(parse(registration_code))
#         @test length(collect(readdir(datadep"Gold Prices in London 1950-2008 (Monthly)"))) > 0
#     end

#     @test_reference "references/CKAN Gold Prices.txt" registration_code
# end

# @testset "data.gov test" begin
#     @test_reference "references/CKAN Consumer Complaint.txt" generate(CKAN(), "https://catalog.data.gov/api/3/action/package_show?id=consumer-complaint-database")
# end

@testset "data.gov.au test" begin
    @test_reference "references/CKAN Hazelwood Fire.txt" generate(CKAN(), "https://data.gov.au/api/3/action/package_show?id=2016-soe-atmosphere-hourly-co-and-24h-pm2-5-concentrations-measured-during-the-hazelwood-mine-fire")
end