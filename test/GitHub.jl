using DataDepsGenerators
using Base.Test

using ReferenceTests

@testset "fivethirtyeight (folders in 1 repo)" begin
    @test_reference "references/538 march.txt" generate(GitHub(), "https://github.com/fivethirtyeight/data/tree/master/march-madness-predictions-2015")
    
    
    @test_reference "references/538 steak.txt" replace(
        generate(GitHub(), "https://github.com/fivethirtyeight/data/tree/master/steak-survey"),
        r"Article.*"s, "") # Delete most of the text harvested from top level readme, as that will go out of date fast 
    
    
    @test_reference "references/538 college.txt" generate(GitHub(), "fivethirtyeight/data/tree/master/college-majors")
end


@testset "BuzzFeedNews (whole repos)" begin
    @test_reference "references/buzzfeed pres-camp.txt" generate(GitHub(), "https://github.com/BuzzFeedNews/presidential-campaign-contributions")
    
    @test_reference "references/buzzfeed primates.txt" generate(GitHub(), "BuzzFeedNews/2015-07-primates")
end