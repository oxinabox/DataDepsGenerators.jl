using DataDepsGenerators:format_checksums
using Test

@testset "Formatting Checksums" begin
    @test  format_checksums("898237b") ==
                    "\"898237b\""
                    
    @test  format_checksums(["898237b", "aba1"]) ==
                "[\"898237b\", \"aba1\"]"
                    
    @test  format_checksums((:md5, "898237b")) ==
                    "(md5, \"898237b\")"

    @test  format_checksums([(:md5, "898237b"),(:md6, "a1237b")]) ==
                "[(md5, \"898237b\"), (md6, \"a1237b\")]"
                
    @test  format_checksums([(:md5, "898237b"), "fafaf"]) ==
            "[(md5, \"898237b\"), \"fafaf\"]"
    

end