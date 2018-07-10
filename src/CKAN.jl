struct CKAN <: DataRepo
end

description(repo::CKAN, mainpage) = mainpage["notes"]

function author(repo::CKAN, mainpage)
    authors = [mainpage["author"]]
    format_authors(authors)
end

maintainer(repo::CKAN, mainpage) = mainpage["maintainer"]

license(repo::CKAN, mainpage) = mainpage["license_title"]

function createDate(repo::CKAN, mainpage)
    rawdate = Dates.Date(mainpage["metadata_created"][1:10], "yyyy-mm-dd")
    Dates.format(rawdate, "U d, yyyy")
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
