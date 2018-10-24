using Test
using DataDeps
using DataDepsGenerators
using ReferenceTests

@testset "CKAN Demo test" begin
    #WARNING: This dataset is actually invalid on CKAN is the original data it references has moved
    # At some point it will break when the data set changes
    @test_reference "references/CKAN Gold Prices.txt" generate(CKAN(), "https://demo.ckan.org/dataset/gold-prices")
end

@testset "data.gov test" begin
    registration_code = generate(CKAN(), "https://catalog.data.gov/api/3/action/package_show?id=consumer-complaint-database")
    
    @testset "Integration Test" begin
        eval(Meta.parse(registration_code))
        @test length(collect(readdir(datadep"Consumer Complaint Database"))) > 0
    end

    @test_reference "references/CKAN Consumer Complaint.txt" registration_code
end

@testset "data.gov.au test" begin
    @test_reference "references/CKAN Hazelwood Fire.txt" generate(CKAN(), "https://data.gov.au/api/3/action/package_show?id=2016-soe-atmosphere-hourly-co-and-24h-pm2-5-concentrations-measured-during-the-hazelwood-mine-fire")
end
