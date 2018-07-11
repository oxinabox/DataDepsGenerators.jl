struct ArcticDataCenter <: KNB
end

function pub_date(repo::ArcticDataCenter, mainpage)
    date_ele = matchall(sel"pubDate", mainpage.root)
    Dates.Date(text_only(first(date_ele)), "yyyy-mm-dd")
end