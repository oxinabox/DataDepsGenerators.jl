struct Dataverse <: DataRepo
end

base_url(::Dataverse) = "https://dataverse.harvard.edu/api/datasets/:persistentId/?persistentId="

function description(repo::Dataverse, mainpage)
    # desc = mainpage["description"]
    # authors = [value["full_name"] for value in mainpage["authors"]]
    # author = format_authors(authors)
    # license = mainpage["license"]["name"] * " (" *mainpage["license"]["url"] * ")"
    # date = mainpage["published_date"]
    # dataset_cite = mainpage["citation"]
    
    # """
    # Author: $(author)
    # License: $(license)
    # Date: $(date)

    # $(desc)

    # Please cite this work:
    # $(dataset_cite)
    # if you use this in your research.
    # """
    ""
end

function get_urls(repo::Dataverse, page)
    urls = []
    for ii in page["latestVersion"]["files"]
        push!(urls, ii["dataFile"]["pidURL"])
    end
    urls
end

function get_checksums(repo::Dataverse, page)
    checksums = []
    for ii in page["latestVersion"]["files"]
        push!(checksums, (:md5, ii["dataFile"]["md5"]))
    end
    checksums
end

function data_fullname(::Dataverse, mainpage)
    # mainpage["title"]
    ""
end

function website(repo::Dataverse, mainpage_url, mainpage)
    # mainpage["url_public_html"]
    ""
end

function mainpage_url(repo::Dataverse, dataname)
    if match_doi(dataname) != nothing
        identifier = match_doi(dataname)
        url = base_url(repo) * "doi:" * identifier
    else
        error("Please use a valid url or DOI")
    end
    JSON.parse(text_only(getpage(url).root))["data"], url
end
