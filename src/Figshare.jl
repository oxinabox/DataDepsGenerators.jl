struct Figshare <: DataRepo
end

base_url(::Figshare) = "https://api.figshare.com/v2/articles"

function description(repo::Figshare, mainpage)
    desc = mainpage["description"]
    authors = [value["full_name"] for value in mainpage["authors"]]
    author = format_authors(authors)
    license = mainpage["license"]["name"] * " (" *mainpage["license"]["url"] * ")"
    date = mainpage["published_date"]
    paper = mainpage["citation"]
    
    escape_multiline_string("""
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc)

    Please cite this paper:
    $(paper)
    if you use this in your research.
    """, "\$")
end

function get_urls(repo::Figshare, page)
    urls = []
    for i in page["files"]
        push!(urls, i["download_url"])
    end
    urls
end

function get_checksums(repo::Figshare, page)
    checksums = []
    for i in page["files"]
        push!(checksums, (:md5, i["computed_md5"]))
    end
    checksums
end

function data_fullname(::Figshare, mainpage)
    mainpage["title"]
end

function website(repo::Figshare, mainpage_url, mainpage)
    mainpage["url_public_html"]
end

function match_figshare(uri::String)
    try
        identifier = match(r"\d{7}", uri).match
        return true, identifier
    catch ErrorException
        return false
    end
end

function mainpage_url(repo::Figshare, dataname)
    #We are making it work for both figshare id or doi
    if match_doi(dataname)[1]
        identifier = match_doi(dataname)[2]
        down_url = base_url(repo) * "?doi=" * identifier
        doi_page = JSON.parse(text_only(getpage(down_url).root))
        url = doi_page[1]["url_public_api"]
    elseif match_figshare(dataname)[1]
        identifier = match_figshare(dataname)[2]
        url = base_url(repo) * "/" *identifier   
    else
        error("Please use a valid url, DOI, or Figshare ID")
    end
    JSON.parse(text_only(getpage(url).root)), url
end