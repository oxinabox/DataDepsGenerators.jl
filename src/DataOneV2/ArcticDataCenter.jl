immutable ArcticDataCenter <: KNB
end

function pub_date(repo::ArcticDataCenter, mainpage)
    date_ele = matchall(sel"pubDate", mainpage.root)
    rawdate = Dates.Date(text_only(first(date_ele)), "yyyy-mm-dd")
    Dates.year(rawdate), Dates.format(rawdate, "U d, yyyy")
end