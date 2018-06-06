using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "CKAN test" begin
    @test_reference "references/CKAN Gold Prices.txt" generate(CKAN(), "https://demo.ckan.org/api/3/action/package_show?id=gold-prices")
    
    #Checking files with multiple files available for download
    @test_reference "references/CKAN District Spending.txt" generate(CKAN(), "https://demo.ckan.org/api/3/action/package_show?id=adur_district_spending")
end
