struct DataCite <: DataRepo
end

base_url(::DataCite) = "https://api.datacite.org/works/"

description(repo::DataCite, mainpage) = handle_null(mainpage["attributes"]["description"])

author(::DataCite, mainpage) = join.([[names[2] for names in value] for value in  mainpage["attributes"]["author"]], " ")

license(::DataCite, mainpage) = handle_null(mainpage["attributes"]["license"])

publishedDate(::DataCite, mainpage) = mainpage["attributes"]["published"]

datasetCite(::DataCite, mainpage) = citation_text(mainpage["id"])

function paperCite(::DataCite, mainpage)
    paper_cite = missing
    for related in mainpage["attributes"]["related-identifiers"]
        if related["relation-type-id"] == "IsSupplementTo"
            paper_cite = citation_text(related["related-identifier"])
            break
        end
    end
    paper_cite
end

function get_urls(repo::DataCite, page)
    urls = ["PUT DOWNLOAD URL HERE"]
    info("DataCite based generation can only generate partial registration blocks, as DataCite metadata does not (currently) include the URL to the resource. You will have to edit in the URL after generation.")
    urls
end

function get_checksums(repo::DataCite, page)
    missing
end

function data_fullname(::DataCite, mainpage)
    mainpage["attributes"]["title"]
end

function website(repo::DataCite, mainpage_url, mainpage)
    replace(mainpage_url, base_url(repo), "https://doi.org/")
end

function mainpage_url(repo::DataCite, dataname)
    if match_doi(dataname) != nothing
        identifier = match_doi(dataname)
        url = base_url(repo) * identifier
        JSON.parse(text_only(getpage(url).root))["data"], url
    else
        error("Please use a valid url")
    end
end
