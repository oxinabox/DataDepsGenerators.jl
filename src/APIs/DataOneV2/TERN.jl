struct TERN <: DataOneV2 end

base_url(::TERN) = "https://dataone.tern.org.au/mn/v2/object/aekos.org.au/collection/nsw.gov.au/nsw_atlas/"

function get_urls(repo::TERN, page)
     links = eachmatch(sel"distribution online url", page.root)
     [text_only(links)]
end

function desc_(repo::TERN, mainpage)
    desc_ele = eachmatch(sel"description", mainpage.root)
    text_only(first(desc_ele))
end

function authors_(repo::TERN, mainpage)
    author_ele = eachmatch(sel"organizationName", mainpage.root)
    [text_only(i) for i in author_ele]
end

function pub_date(repo::TERN, mainpage)
    date_ele = eachmatch(sel"temporalCoverage rangeOfDates endDate", mainpage.root)
    Dates.Date(text_only(first(date_ele)), "yyyy-mm-dd")
end

function data_fullname(::TERN, mainpage)
    text_only(first(eachmatch(sel"project title", mainpage.root)))
end