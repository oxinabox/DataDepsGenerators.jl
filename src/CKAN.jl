struct CKAN <: DataRepo
end

base_url(::CKAN) = "https://demo.ckan.org/api/3/action/package_show?id="

function description(repo::CKAN, mainpage)
    desc = mainpage["notes"]
    authors = [mainpage["author"], mainpage["maintainer"] * " (Maintainer)"]
    author = format_authors(authors)
    license = mainpage["license_title"]
    rawdate = Dates.Date(mainpage["metadata_created"][1:10], "yyyy-mm-dd")
    date = Dates.format(rawdate, "U d, yyyy")
    dataset = mainpage["name"]
    
    final = escape_multiline_string("""
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc)

    Please cite this dataset:
    $(dataset)
    if you use this in your research.
    """, "\$")
end

function get_urls(repo::CKAN, page)
    urls = []
    for i = 1:page["num_resources"]
        push!(urls, page["resources"][i]["url"])
    end
    urls
end

function get_checksums(repo::CKAN, page)
    checksums = []
    for i = 1:page["num_resources"]
        if page["resources"][i]["hash"] != "" push!(checksums, page["resources"][i]["hash"]) end
    end
    checksums
end

function data_fullname(::CKAN, mainpage)
    mainpage["title"]
end

function website(::CKAN, mainpage_url)
    replace(mainpage_url, "/api/3/action/package_show?id=", "/dataset/")
end

function mainpage_url(repo::CKAN, dataname)
    if startswith(dataname, "http")
        url = replace(dataname, "/dataset/", "/api/3/action/package_show?id=")
    else # not a URL
        url = base_url(repo) * dataname
        dataname = "https://demo.ckan.org/dataset/" * dataname
    end
    JSON.parse(text_only(getpage(url).root))["result"], dataname
end