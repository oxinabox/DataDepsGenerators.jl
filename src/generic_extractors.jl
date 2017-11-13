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
