using DataDeps
using DataDepsGenerators
using Test
using ReferenceTests

"""
URLS tend to go out of date fast on github (as we always generate using the latest commit)
so strip them from the recorded reference
"""
function discard_urls(code)
    replace(code, r"http.*?([\s\"\)])" => s"<URL>\1")
end

@testset "fivethirtyeight (folders in 1 repo)" begin
    @testset "538 March" begin
        registration_code = generate(GitHub(), "https://github.com/fivethirtyeight/data/tree/master/march-madness-predictions-2015")

        @testset "Integration Test" begin
            eval(Meta.parse(registration_code))
            @test length(collect(readdir(datadep"March Madness Predictions"))) > 0
        end

        @test_reference "references/538 march.txt" discard_urls(registration_code)
    end
    
    @test_reference "references/538 steak.txt" discard_urls(replace(
        generate(GitHub(), "https://github.com/fivethirtyeight/data/tree/master/steak-survey"),
        r"Article.*"s=> "")) # Delete most of the text harvested from top level readme, as that will go out of date fast 
    
    
    @test_reference "references/538 college.txt" discard_urls(generate(GitHub(), "fivethirtyeight/data/tree/master/college-majors"))
end


@testset "BuzzFeedNews (whole repos)" begin
    @testset "Pres Camp" begin
        registration_code = generate(GitHub(), "https://github.com/BuzzFeedNews/presidential-campaign-contributions")
        
		@testset "Integration Test" begin
			eval(Meta.parse(registration_code)) # evaluate the new code
			@test length(collect(readdir(datadep"Presidential Campaign Contributions"))) > 0
		end
		
        @test_reference "references/buzzfeed pres-camp.txt" discard_urls(registration_code) # See if new code is same as old
	end
    
    @test_reference "references/buzzfeed primates.txt" discard_urls(generate(GitHub(), "BuzzFeedNews/2015-07-primates"))
end
