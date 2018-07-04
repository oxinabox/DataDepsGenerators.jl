abstract type JSONLD <: DataRepo
end

export JSONLD_Web, JSONLD_DOI

include("JSONLD_Web.jl")
include("JSONLD_DOI.jl")

function description(repo::JSONLD, mainpage)
    desc = handle_keys("description", "", mainpage)
    authors = handle_keys("author", "creator", mainpage)
    if authors != nothing
        stripauthors = [handle_keys("name", "", ii) for ii in authors if handle_keys("name", "", ii) != nothing]
        author = format_authors(stripauthors)
    else
        author = "Unknown Author"
    end
    license = get_license(mainpage)
    rawdate = Dates.DateTime(handle_keys("datePublished", "dateModified", mainpage))
    date = Dates.format(rawdate, "U d, yyyy")

    """
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc)
    """
end

function get_license(mainpage)
    license = handle_keys("license", "", mainpage)
    if license != nothing
        if isa(license, String)
            return license
        elseif isa(license, Dict)
            return handle_keys("url", "text", license)
        end
    end
end

function handle_keys(key1::String, key2::String, json)
    if get(json, key1, nothing) == nothing
        return get(json, key2, nothing)
    else
        return get(json, key1, nothing)
    end
end

function get_urls(repo::JSONLD, page)
    urls = []
    url_list = handle_keys("distribution", "", page)
    if url_list != nothing
        urls = [handle_keys("contentUrl", "", ii) for ii in url_list if handle_keys("contentUrl", "", ii) != nothing]
    else
        urls = []
    end
    urls
end

function get_checksums(repo::JSONLD, page)
    checksums = []
    checksums
end

function data_fullname(::JSONLD, mainpage)
    mainpage["name"]
end

function website(::JSONLD, mainpage_url, mainpage)
    mainpage_url
end

function mainpage_url(repo::JSONLD, dataname)
    #We are making it work for both figshare id or doi
    page=getpage(dataname)
    pattern = sel"script[type=\"application/ld+json\"]"
    jsonld_blocks = matchall(pattern, page.root)
    if length(jsonld_blocks)==0
        error("No JSON-LD Linked Data Found")
    end
    @assert length(jsonld_blocks)==1
    script_block = text_only(first(jsonld_blocks))
    json = JSON.parse(script_block)
    json, dataname
end