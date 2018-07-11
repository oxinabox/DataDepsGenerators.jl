struct Figshare <: DataRepo
end

base_url(::Figshare) = "https://api.figshare.com/v2/articles"

description(repo::Figshare, mainpage) = mainpage["description"]

author(::Figshare, mainpage) = [value["full_name"] for value in mainpage["authors"]]

license(::Figshare, mainpage) = mainpage["license"]["name"] * " (" *mainpage["license"]["url"] * ")"

publishedDate(::Figshare, mainpage) = mainpage["published_date"]

datasetCite(::Figshare, mainpage) = mainpage["citation"]

function get_urls(repo::Figshare, page)
    urls = []
    for ii in page["files"]
        push!(urls, ii["download_url"])
    end
    urls
end

function get_checksums(repo::Figshare, page)
    warn("Generated registration block uses MD5 hashes, the MD5.jl package will be required.")
    [(:md5, ii["computed_md5"]) for ii in page["files"]]
end

function data_fullname(::Figshare, mainpage)
    mainpage["title"]
end

function website(repo::Figshare, mainpage_url, mainpage)
    mainpage["url_public_html"]
end

function match_figshare(uri::String)
    identifier_match = match(r"\d{7}", uri)
    identifier_match === nothing ? nothing : identifier_match.match
end

function mainpage_url(repo::Figshare, dataname)
    #We are making it work for both figshare id or doi
    if match_doi(dataname) != nothing
        identifier = match_doi(dataname)
        down_url = base_url(repo) * "?doi=" * identifier
        doi_page = JSON.parse(text_only(getpage(down_url).root))
        url = doi_page[1]["url_public_api"]
    elseif match_figshare(dataname)!= nothing
        identifier = match_figshare(dataname)
        url = base_url(repo) * "/" *identifier
    else
        error("Please use a valid url, DOI, or Figshare ID")
    end
    JSON.parse(text_only(getpage(url).root)), url
end
