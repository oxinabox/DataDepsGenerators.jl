struct DataCite <: DataRepo
end

base_url(::DataCite) = "https://api.datacite.org/works/"

function description(repo::DataCite, mainpage)
    attributes = mainpage["attributes"]
    desc = attributes["description"]
    authors = join.([[names[2] for names in value] for value in attributes["author"]], " ")
    author = format_authors(authors)
    license = attributes["license"]
    date = attributes["published"]
    dataset_cite = citation_text(mainpage["id"])
    
    paper_cite = nothing
    for related in attributes["related-identifiers"]
        if related["relation-type-id"] == "IsSupplementTo"
            paper_cite = citation_text(related["related-identifier"])
            break
        end
    end
    

    escape_multiline_string("""
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc != nothing ? desc : "" )

    Please cite this dataset:
    $(dataset_cite)
    $(paper_cite != nothing ? "and this paper: " * paper_cite : "")
    if you use this in your research.
    """, "\$")
end

function get_urls(repo::DataCite, page)
    urls = ["PUT DOWNLOAD URL HERE"]
    info("DataCite based generation can only generate partial registration blocks, as DataCite metadata does not (currently) include the URL to the resource. You will have to edit in the URL after generation.")
    urls
end

function get_checksums(repo::DataCite, page)
    nothing
end

function data_fullname(::DataCite, mainpage)
    mainpage["attributes"]["title"]
end

function website(repo::DataCite, mainpage_url, mainpage)
    replace(mainpage_url, base_url(repo), "https://doi.org/")
end

function mainpage_url(repo::DataCite, dataname)
    try
        identifier = match_doi(dataname)
        url = base_url(repo) * identifier
        JSON.parse(text_only(getpage(url).root))["data"], url
    catch ErrorException
        error("Please use a valid url")
    end
end
