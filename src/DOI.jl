struct DOI
end

function generate(repo::DOI, dataname, shortname = nothing)
    if match_doi(dataname) != nothing
        url = startswith(dataname, "http") ? dataname : joinpath("https://doi.org/", dataname)
        resp = HTTP.get(url, ["Accept"=>"application/rdf+xml"]; forwardheaders=true)
        check = resp.body |> String |> strip
        if contains(check, "datacite")
            generate(DataCite(), dataname, shortname)
        elseif contains(check, "crossref")
            #To be implemented
            # generate(CrossRef(), dataname, shortname)
        elseif contains(check, "medra")
            # generate(mEDRA(), dataname, shortname)
        else
            warn("It seems your DOI is not in the records. Are you sure the DOI is correct?")
        end
    else
        error("Please use a valid url or DOI")
    end
end