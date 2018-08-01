abstract type DataOneV2 <: DataRepo end

export KNB, TERN
include("KNB.jl")
include("TERN.jl")

description(repo::DataOneV2, mainpage) = try desc_(repo, mainpage) catch missing end

author(repo::DataOneV2, mainpage) = try authors_(repo, mainpage) catch missing end

license(repo::DataOneV2, mainpage) = try license_(repo, mainpage) catch missing end

published_date(repo::DataOneV2, mainpage) = try pub_date(repo, mainpage) catch missing end

function license_(repo::DataOneV2, mainpage)
    try
        license_ele = matchall(sel"intellectualRights", mainpage.root)
        if length(license_ele) > 0
            text_only(first(license_ele))
        else
            ""
        end
    catch
        missing
    end
end

function paper_title_(repo::DataOneV2, mainpage)
    try
        paper_title_ele = matchall(sel"title", mainpage.root)
        if length(paper_title_ele) > 0
            text_only(first(paper_title_ele))
        else
            ""
        end
    catch
        missing
    end
end
