abstract type KNB <: DataOneV2 end

base_url(::KNB) = "https://knb.ecoinformatics.org/knb/d1/mn/v2/object/"

export ArcticDataCenter, KnowledgeNetworkforBiocomplexity
include("ArcticDataCenter.jl")
include("KnowledgeNetworkforBiocomplexity.jl")

function get_urls(repo::KNB, page)
    urls = []
    links = eachmatch(sel"distribution online", page.root)
    url_links = [replace(text_only(i), "ecogrid://knb/"=>base_url(repo)) for i in links]
    push!(urls, url_links)
    urls
end

function website(repo::KNB, mainpage_url, mainpage)
    replace(mainpage_url, base_url(repo) => "http://dx.doi.org/")
end

function desc_(repo::KNB, mainpage)
    desc_ele = eachmatch(sel"description para", mainpage.root)
    text_only(first(desc_ele))
end

function authors_(repo::KNB, mainpage)
    author_ele = eachmatch(sel"individualName", mainpage.root)
    [text_only(i) for i in author_ele if occursin("creator", string(i.parent))]
end

function pub_date(repo::KNB, mainpage)
    date_ele = eachmatch(sel"pubDate", mainpage.root)
    Dates.Date(text_only(first(date_ele)), "yyyy-mm-dd")
end

function data_fullname(::KNB, mainpage)
    text_only(first(eachmatch(sel"description title", mainpage.root)))
end
