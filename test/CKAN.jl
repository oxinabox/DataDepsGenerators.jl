using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "CKAN test" begin
    @test_reference "references/CKAN Gold Prices.txt" generate(CKAN(), "https://demo.ckan.org/dataset/gold-prices")
    
    #Checking files with multiple files available for download
    @test_reference "references/CKAN District Spending.txt" generate(CKAN(), "adur_district_spending")
end
