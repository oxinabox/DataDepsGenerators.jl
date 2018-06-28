struct CKAN <: DataRepo
end

function description(repo::CKAN, mainpage)
    desc = mainpage["notes"]
    authors = [mainpage["author"]]
    author = format_authors(authors)
    maintainer = mainpage["maintainer"]
    license = mainpage["license_title"]
    rawdate = Dates.Date(mainpage["metadata_created"][1:10], "yyyy-mm-dd")
    date = Dates.format(rawdate, "U d, yyyy")
    
    final = escape_multiline_string("""
    Author: $(author)
    License: $(license)
    Date: $(date)
    Maintainer: $(maintainer)

    $(desc)

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
    nothing
end

function data_fullname(::CKAN, mainpage)
    mainpage["title"]
end

function website(repo::CKAN, mainpage_url, mainpage)
    replace(mainpage_url, "/api/3/action/package_show?id=", "/dataset/")
end

function mainpage_url(repo::CKAN, dataname)
    if startswith(dataname, "http")
        url = replace(dataname, "/dataset/", "/api/3/action/package_show?id=")
    else
        error("Please use a valid url")
    end
    JSON.parse(text_only(getpage(url).root))["result"], dataname
end