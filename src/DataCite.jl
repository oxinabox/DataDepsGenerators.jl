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
    paper = format_papers(authors, date, attributes["title"] * " [Data set]. " * attributes["container-title"] * ".", mainpage["id"])
    
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

function get_urls(repo::DataCite, page)
    urls = []
    urls
end

function get_checksums(repo::DataCite, page)
    nothing
end

function data_fullname(::DataCite, mainpage)
    mainpage["attributes"]["title"]
end

function website(repo::DataCite, mainpage_url)
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