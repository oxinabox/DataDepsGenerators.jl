abstract type KNB <: DataOnev2 end

base_url(::KNB) = "https://knb.ecoinformatics.org/knb/d1/mn/v2/"

export ArcticDataCenter, KnowledgeNetworkforBiocomplexity
include("ArcticDataCenter.jl")
include("KnowledgeNetworkforBiocomplexity.jl")

function get_urls(repo::KNB, page)
    urls = []
    links = matchall(sel"distribution online", page.root)
    url_links = [replace(text_only(i), "ecogrid://knb/", "https://knb.ecoinformatics.org/knb/d1/mn/v2/object/") for i in links]
    push!(urls, url_links)
    urls
end

function website(::KNB, mainpage_url)
    replace(mainpage_url, "https://knb.ecoinformatics.org/knb/d1/mn/v2/object/", "http://dx.doi.org/")
end