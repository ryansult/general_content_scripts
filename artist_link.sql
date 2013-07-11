--FIRST, REPLACE ALL OCCURANCES OF your_table WITH THE WORKTABLE NAME and your_artist with the artistname column

drop table trackmodel_artist_link;

select distinct t.artistid, ar.row_number, link_artistname into trackmodel_artist_link
from trackmodel_track_link ttl
inner join amw_track t on ttl.productid=t.productid
inner join artistmodel_artist_rank ar on t.artistid=ar.artistid;

alter table your_table
add artistid int;

alter table your_table
add match_confidence_a int;

alter table your_table
add artist_rank int;

alter table your_table
add link_artistname nvarchar(1024);

--set link values
--REPLACE your_artistname WITH WORKTABLE ARTISTNAME COLUMN NAME
update your_table
set link_artistname=your_artist;

update your_table set link_artistname=aaa.proper_string from your_table yt inner join artistmodel_artist_alias aaa on aaa.alias_string=yt.link_artistname;

--artistname string standardization
-- title / author string normalization for flipped your_artistnames
update your_table
set link_artistname = radiofuse.dbo.content_string_normalization(lower(link_artistname));

-- split the strings for flipped your_artistnames
update your_table
set link_artistname=radiofuse.dbo.content_string_slice(link_artistname,'featuring');

--remove any remaning special chars and spaces for flipped your_artistnames
update your_table
set link_artistname=radiofuse.dbo.remove_non_alphanum(link_artistname);


--find matches
update your_table
set artistid=z.artistid, match_confidence_a=100
from (
select distinct y.link_artistname, tal2.artistid
from
(select min(tal.row_number) as row_number, m.link_artistname
from trackmodel_artist_link tal, your_table m
where m.artistid is null 
and tal.link_artistname collate Latin1_General_CI_AI = m.link_artistname collate Latin1_General_CI_AI
group by m.link_artistname) as y, trackmodel_artist_link tal2
where y.row_number=tal2.row_number) as z, your_table m2
where z.link_artistname=m2.link_artistname and m2.artistid is null;


update your_table
set artistid=z.artistid, match_confidence_a=95
from (
select distinct y.link_artistname, tal2.artistid
from
(select min(tal.row_number) as row_number, m.link_artistname
from trackmodel_artist_link tal, your_table m
where m.artistid is null 
and substring((tal.link_artistname collate Latin1_General_CI_AI), 1, 20) = substring((m.link_artistname collate Latin1_General_CI_AI), 1,20)
group by m.link_artistname) as y, trackmodel_artist_link tal2
where y.row_number=tal2.row_number) as z, your_table m2
where z.link_artistname=m2.link_artistname and m2.artistid is null;


update your_table
set artistid=z.artistid, match_confidence_a=90
from (
select distinct y.link_artistname, tal2.artistid
from
(select min(tal.row_number) as row_number, m.link_artistname
from trackmodel_artist_link tal, your_table m
where m.artistid is null 
and substring((tal.link_artistname collate Latin1_General_CI_AI), 1, 15) = substring((m.link_artistname collate Latin1_General_CI_AI), 1,15)
group by m.link_artistname) as y, trackmodel_artist_link tal2
where y.row_number=tal2.row_number) as z, your_table m2
where z.link_artistname=m2.link_artistname and m2.artistid is null;

update your_table
set artistid=z.artistid, match_confidence_a=80
from (
select distinct y.link_artistname, tal2.artistid
from
(select min(tal.row_number) as row_number, m.link_artistname
from trackmodel_artist_link tal, your_table m
where m.artistid is null 
and substring((tal.link_artistname collate Latin1_General_CI_AI), 1, 12) = substring((m.link_artistname collate Latin1_General_CI_AI), 1,12)
group by m.link_artistname) as y, trackmodel_artist_link tal2
where y.row_number=tal2.row_number) as z, your_table m2
where z.link_artistname=m2.link_artistname and m2.artistid is null;

update your_table
set artistid=z.artistid, match_confidence_a=70
from (
select distinct y.link_artistname, tal2.artistid
from
(select min(tal.row_number) as row_number, m.link_artistname
from trackmodel_artist_link tal, your_table m
where m.artistid is null 
and substring((tal.link_artistname collate Latin1_General_CI_AI), 1, 10) = substring((m.link_artistname collate Latin1_General_CI_AI), 1,10)
group by m.link_artistname) as y, trackmodel_artist_link tal2
where y.row_number=tal2.row_number) as z, your_table m2
where z.link_artistname=m2.link_artistname and m2.artistid is null;

update your_table
set artistid=z.artistid, match_confidence_a=60
from (
select distinct y.link_artistname, tal2.artistid
from
(select min(tal.row_number) as row_number, m.link_artistname
from trackmodel_artist_link tal, your_table m
where m.artistid is null 
and substring((tal.link_artistname collate Latin1_General_CI_AI), 1, 8) = substring((m.link_artistname collate Latin1_General_CI_AI), 1,8)
group by m.link_artistname) as y, trackmodel_artist_link tal2
where y.row_number=tal2.row_number) as z, your_table m2
where z.link_artistname=m2.link_artistname and m2.artistid is null;

update your_table
set artistid=z.artistid, match_confidence_a=50
from (
select distinct y.link_artistname, tal2.artistid
from
(select min(tal.row_number) as row_number, m.link_artistname
from trackmodel_artist_link tal, your_table m
where m.artistid is null 
and substring((tal.link_artistname collate Latin1_General_CI_AI), 1, 6) = substring((m.link_artistname collate Latin1_General_CI_AI), 1,6)
group by m.link_artistname) as y, trackmodel_artist_link tal2
where y.row_number=tal2.row_number) as z, your_table m2
where z.link_artistname=m2.link_artistname and m2.artistid is null;



--add matched artistnames and titles
alter table your_table
add matched_artistname nvarchar(1024);


update your_table
set matched_artistname=a.artistname
from your_table m inner join amw_artist a on m.artistid=a.artistid;

--view results
select m.*
from your_table m
where artistid is not null
order by match_confidence_a desc;