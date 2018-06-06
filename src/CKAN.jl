using JSON

immutable CKAN <: DataRepo
end

base_url(::CKAN) = "https://datadryad.org/mn/object/http://dx.doi.org/"

function description(repo::CKAN, mainpage)
    j = JSON.parse(text_only(mainpage.root))
    desc = j["result"]["notes"]
    authors = [j["result"]["notes"]]
    author = format_authors(authors)
    license = j["result"]["license_title"]
    rawdate = Dates.Date(j["result"]["metadata_created"][1:10], "yyyy-mm-dd")
    date = Dates.format(rawdate, "U d, yyyy")
    dataset = j["result"]["name"]
    
    final = escape_multiline_string("""
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc)

    Please cite this paper:
    $(dataset)
    if you use this in your research.
    """, "\$")
end

function get_urls(repo::CKAN, page)
    j = JSON.parse(text_only(page.root))
    urls = []
    for i = 1:j["result"]["num_resources"]
        push!(urls, j["result"]["resources"][i]["url"])
    end
    urls
end

function get_checksums(repo::CKAN, page)
    j = JSON.parse(text_only(page.root))
    checksums = []
    for i = 1:j["result"]["num_resources"]
        if j["result"]["resources"][i]["hash"] != "" push!(checksums, j["result"]["resources"][i]["hash"]) end
    end
    checksums
end

function data_fullname(::CKAN, mainpage)
    j = JSON.parse(text_only(mainpage.root))
    j["result"]["title"]
end

function website(::CKAN, mainpage_url)
    replace(mainpage_url, "/api/3/action/package_show?id=", "/dataset/")
end