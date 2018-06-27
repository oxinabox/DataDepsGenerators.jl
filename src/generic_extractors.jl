"""
    links_from_webserver_index(url)

Extracts all the content links from a webservers directory index page.
These follow a pretty standard form.
This one is tested so far on Apache/2.2.15
"""
function get_dataurls_from_webserver_index(datapage_url)
    datapage = getpage(datapage_url)

    data_links = matchall(sel"td a", datapage.root)
    @assert( text_only(data_links[1]) == "Parent Directory", repr(data_links[1]))

    data_hrefs = getindex.(attrs.(data_links[2:end]), "href")
    data_urls = joinpath.(datapage_url, data_hrefs)
end


"""
    citation_text(doi)

Uses the DOI formatted citation service to generate citation text for a given DOI.
This works for DOI's issued by: CrossRef, DataCite, and mEDRA.

See https://citation.crosscite.org/docs.html#sec-4-1
"""
function citation_text(doi)
    # GOLDPLATE: this could support so much more for different styles, but we don't need it
    url = startswith(doi, "http") ? doi : joinpath("https://doi.org/", doi)
    resp = HTTP.get(url, ["Accept"=>"text/x-bibliography"]; forwardheaders=true)
    resp.body |> String |> strip
end

