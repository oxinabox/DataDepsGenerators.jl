struct JSONLD_DOI <: JSONLD end

function mainpage_url(repo::JSONLD_DOI, dataname)
    if match_doi(dataname) != nothing
        url = joinpath("https://data.datacite.org/", match_doi(dataname))
        resp = HTTP.get(url, ["Accept"=>"application/vnd.schemaorg.ld+json"]; forwardheaders=true)
        json = JSON.parse(resp.body |> String |> strip)
    end
    json, dataname
end