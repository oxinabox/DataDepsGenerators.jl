struct TERN <: DataOneV2 end

base_url(::TERN) = "https://dataone.tern.org.au/mn/v2/object/aekos.org.au/collection/nsw.gov.au/nsw_atlas/"

function get_urls(repo::TERN, page)
     links = matchall(sel"distribution online url", page.root)
     [text_only(links)]
end

function desc_(repo::TERN, mainpage)
    desc_ele = matchall(sel"description", mainpage.root)
    text_only(first(desc_ele))
end

function authors_(repo::TERN, mainpage)
    author_ele = matchall(sel"organizationName", mainpage.root)
    [text_only(i) for i in author_ele]
end

function pub_date(repo::TERN, mainpage)
    date_ele = matchall(sel"temporalCoverage rangeOfDates endDate", mainpage.root)
    rawdate = Dates.Date(text_only(first(date_ele)), "yyyy-mm-dd")
    Dates.year(rawdate), Dates.format(rawdate, "U d, yyyy")
end

function data_fullname(::TERN, mainpage)
    text_only(first(matchall(sel"project title", mainpage.root)))
end