struct CKAN <: DataRepo
end

description(repo::CKAN, mainpage) = mainpage["notes"]

author(repo::CKAN, mainpage) = [mainpage["author"]]

maintainer(repo::CKAN, mainpage) = mainpage["maintainer"]

license(repo::CKAN, mainpage) = mainpage["license_title"]

function create_date(repo::CKAN, mainpage)
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

data_fullname(::CKAN, mainpage) = mainpage["title"]

function website(repo::CKAN, mainpage_url, mainpage)
    replace(mainpage_url, "/api/3/action/package_show?id=" =>  "/dataset/")
end

function mainpage_url(repo::CKAN, dataname)
    if startswith(dataname, "http")
        url = replace(dataname, "/dataset/" =>  "/api/3/action/package_show?id=")
        return JSON.parse(text_only(getpage(url).root))["result"], dataname
    else
        # error("Please use a valid url")
        throw(GeneratorError(repo))
    end
end
