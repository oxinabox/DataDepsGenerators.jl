struct JSONLD_Web <: JSONLD end

function mainpage_url(repo::JSONLD_Web, dataname)
    page=getpage(dataname)
    pattern = sel"script[type=\"application/ld+json\"]"
    jsonld_blocks = matchall(pattern, page.root)
    if length(jsonld_blocks)==0
        error("No JSON-LD Linked Data Found")
    end
    @assert length(jsonld_blocks)==1
    script_block = text_only(first(jsonld_blocks))
    json = JSON.parse(script_block)
    json, dataname
end