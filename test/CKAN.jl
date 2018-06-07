using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "CKAN Demo test" begin
    @test_reference "references/CKAN Gold Prices.txt" generate(CKAN(), "https://demo.ckan.org/dataset/gold-prices")
end

@testset "data.gov test" begin
    @test_reference "references/CKAN Consumer Complaint.txt" generate(CKAN(), "https://catalog.data.gov/api/3/action/package_show?id=consumer-complaint-database")
end

@testset "data.gov.au test" begin
    @test_reference "references/CKAN Hazelwood Fire.txt" generate(CKAN(), "https://data.gov.au/api/3/action/package_show?id=2016-soe-atmosphere-hourly-co-and-24h-pm2-5-concentrations-measured-during-the-hazelwood-mine-fire")
end