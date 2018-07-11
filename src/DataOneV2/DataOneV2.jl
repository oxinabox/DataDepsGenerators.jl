abstract type DataOneV2 <: DataRepo end

export KNB, TERN
include("KNB.jl")
include("TERN.jl")

description(repo::DataOneV2, mainpage) = desc_(repo, mainpage)

author(repo::DataOneV2, mainpage) = authors_(repo, mainpage)

license(repo::DataOneV2, mainpage) = license_(repo, mainpage)

published_date(repo::DataOneV2, mainpage) = pub_date(repo, mainpage)

get_urls(repo::DataOneV2, page) = []

function license_(repo::DataOneV2, mainpage)
    license_ele = matchall(sel"intellectualRights", mainpage.root)
    if length(license_ele) > 0
        text_only(first(license_ele))
    else
        ""
    end
end

function paper_title_(repo::DataOneV2, mainpage)
    paper_title_ele = matchall(sel"title", mainpage.root)
    if length(paper_title_ele) > 0
        text_only(first(paper_title_ele))
    else
        ""
    end
end
