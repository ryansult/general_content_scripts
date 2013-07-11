--first, replace all occurances of the below strings:
--your_table, your_artistname, your_title

--STEP 1
alter table your_table
add productid int;

alter table your_table
add match_confidence int;

alter table your_table
add link_title nvarchar(1024);

alter table your_table
add link_artistname nvarchar(1024);

alter table your_table
add flipped_your_artistname nvarchar(1);

alter table your_table
add your_title_par nvarchar(1);


--set link values
update your_table
set link_title=your_title;

update your_table
set link_artistname=your_artistname;

update your_table set link_artistname=aaa.proper_string from your_table yt inner join ihrdwh..artistmodel_artist_alias aaa on aaa.alias_string=yt.link_artistname;

-- title / author string normalization
update your_table
set link_title = radiofuse.dbo.content_string_normalization(lower(link_title))
  , link_artistname = radiofuse.dbo.content_string_normalization(lower(link_artistname));

-- split the strings
update your_table
set link_title=radiofuse.dbo.content_string_slice(link_title,'featuring')
, link_artistname=radiofuse.dbo.content_string_slice(link_artistname,'featuring');

--remove any remaning special chars and spaces
update your_table
set link_title=radiofuse.dbo.remove_non_alphanum(link_title)
  , link_artistname=radiofuse.dbo.remove_non_alphanum(link_artistname);


--add isrc
alter table your_table
add link_isrc nvarchar(255);

alter table your_table
add duration real;

update your_table
set link_isrc=lower(ihrdwh.dbo.remove_non_alphanum(t.isrc)), duration=t.duration
from your_table ttl, ihrdwh..amw_track t
where ttl.productid=t.productid;

create index ttl_isrc
on your_table (link_isrc);

--STEP 2
--find matches
--skip first one if you don't have isrc
update your_table
set productid=ttl.productid, match_confidence=100
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null and ttl.link_isrc=m.link_isrc 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,6)=substring((m.link_artistname collate latin1_general_ci_ai), 1,6) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,6)=substring((m.link_title collate latin1_general_ci_ai), 1,6) and m.productid is null;

--skip if you don't have duration
update your_table
set productid=z.productid, match_confidence=100
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,15)=substring((m.link_artistname collate latin1_general_ci_ai), 1,15) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,15)=substring((m.link_title collate latin1_general_ci_ai), 1,15)
and m.duration between ttl.duration+4 and ttl.duration-4
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null;

--skip if you don't have duration
update your_table
set productid=z.productid, match_confidence=99
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,8)=substring((m.link_artistname collate latin1_general_ci_ai), 1,8) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,8)=substring((m.link_title collate latin1_general_ci_ai), 1,8)
and m.duration between ttl.duration+4 and ttl.duration-4
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null;

--start here if you have only artist and your_title
update your_table
set productid=z.productid, match_confidence=98
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and ttl.link_artistname collate latin1_general_ci_ai = m.link_artistname collate latin1_general_ci_ai
and ttl.link_title collate latin1_general_ci_ai = m.link_title collate latin1_general_ci_ai
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null;

update your_table
set productid=z.productid, match_confidence=95
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,12)=substring((m.link_artistname collate latin1_general_ci_ai), 1,12) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,12)=substring((m.link_title collate latin1_general_ci_ai), 1,12)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null;

update your_table
set productid=z.productid, match_confidence=80
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,8)=substring((m.link_artistname collate latin1_general_ci_ai), 1,8) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,8)=substring((m.link_title collate latin1_general_ci_ai), 1,8)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null;

update your_table
set productid=z.productid, match_confidence=60
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,6)=substring((m.link_artistname collate latin1_general_ci_ai), 1,6) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,6)=substring((m.link_title collate latin1_general_ci_ai), 1,6)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null;

update your_table
set productid=z.productid, match_confidence=50
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,6)=substring((m.link_artistname collate latin1_general_ci_ai), 1,6) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,4)=substring((m.link_title collate latin1_general_ci_ai), 1,4)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null;

update your_table
set productid=z.productid, match_confidence=25
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,4)=substring((m.link_artistname collate latin1_general_ci_ai), 1,4) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,4)=substring((m.link_title collate latin1_general_ci_ai), 1,4)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null;

--STEP 3
--flip your_artistname
update your_table
set flipped_your_artistname='x', link_artistname=substring(your_artistname, charindex(', ', your_artistname)+2, len(your_artistname))+' '+
substring(your_artistname, 1, charindex(', ', your_artistname)-1)
where match_confidence is null and len(your_artistname)-len(replace(your_artistname, ' ', ''))=1 and your_artistname like '%, %'
and len(your_artistname)-len(replace(your_artistname, ',', ''))=1 and your_artistname not like '%,jr%';

-- title / author string normalization for flipped your_artistnames
update your_table
set link_artistname = radiofuse.dbo.content_string_normalization(lower(link_artistname))
where flipped_your_artistname='x';

-- split the strings for flipped your_artistnames
update your_table
set link_artistname=radiofuse.dbo.content_string_slice(link_artistname,'featuring')
where flipped_your_artistname='x';

--remove any remaning special chars and spaces for flipped your_artistnames
update your_table
set link_artistname=radiofuse.dbo.remove_non_alphanum(link_artistname)
where flipped_your_artistname='x';
  

--STEP 4
--find matches for flipped your_artistnames
--skip first one if you don't have isrc
update your_table
set productid=ttl.productid, match_confidence=100
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null and ttl.isrc=m.link_isrc 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,6)=substring((m.link_artistname collate latin1_general_ci_ai), 1,6) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,6)=substring((m.link_title collate latin1_general_ci_ai), 1,6) and m.productid is null and flipped_your_artistname='x';

--skip if you don't have duration
update your_table
set productid=z.productid, match_confidence=100
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,15)=substring((m.link_artistname collate latin1_general_ci_ai), 1,15) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,15)=substring((m.link_title collate latin1_general_ci_ai), 1,15)
and m.duration between ttl.duration+4 and ttl.duration-4
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and flipped_your_artistname='x';

--skip if you don't have duration
update your_table
set productid=z.productid, match_confidence=99
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,8)=substring((m.link_artistname collate latin1_general_ci_ai), 1,8) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,8)=substring((m.link_title collate latin1_general_ci_ai), 1,8)
and m.duration between ttl.duration+4 and ttl.duration-4
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and flipped_your_artistname='x';

--start here if you have only artist and your_title
update your_table
set productid=z.productid, match_confidence=98
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and ttl.link_artistname collate latin1_general_ci_ai = m.link_artistname collate latin1_general_ci_ai
and ttl.link_title collate latin1_general_ci_ai = m.link_title collate latin1_general_ci_ai
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and flipped_your_artistname='x';

update your_table
set productid=z.productid, match_confidence=95
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,12)=substring((m.link_artistname collate latin1_general_ci_ai), 1,12) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,12)=substring((m.link_title collate latin1_general_ci_ai), 1,12)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and flipped_your_artistname='x';

update your_table
set productid=z.productid, match_confidence=80
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,8)=substring((m.link_artistname collate latin1_general_ci_ai), 1,8) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,8)=substring((m.link_title collate latin1_general_ci_ai), 1,8)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and flipped_your_artistname='x';

update your_table
set productid=z.productid, match_confidence=60
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,6)=substring((m.link_artistname collate latin1_general_ci_ai), 1,6) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,6)=substring((m.link_title collate latin1_general_ci_ai), 1,6)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and flipped_your_artistname='x';

update your_table
set productid=z.productid, match_confidence=50
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,6)=substring((m.link_artistname collate latin1_general_ci_ai), 1,6) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,4)=substring((m.link_title collate latin1_general_ci_ai), 1,4)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and flipped_your_artistname='x';

update your_table
set productid=z.productid, match_confidence=25
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,4)=substring((m.link_artistname collate latin1_general_ci_ai), 1,4) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,4)=substring((m.link_title collate latin1_general_ci_ai), 1,4)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and flipped_your_artistname='x';

--STEP 5
--remove parentheticals
update your_table
set your_title_par='x', link_title = substring(your_title, 1, (charindex('(', your_title)))
from your_table m
where your_title like '%(%' and your_title not like '(%' and m.productid is null; 

update your_table
set your_title_par='x', link_title = substring(your_title, 1, (charindex('[', your_title)-1))
from your_table m
where your_title like '%[[]%' and your_title not like '[[]%' and m.productid is null; 


-- title / author string normalization
update your_table
set link_title = radiofuse.dbo.content_string_normalization(lower(link_title))
where your_title_par='x';

-- split the strings
update your_table
set link_title=radiofuse.dbo.content_string_slice(link_title,'featuring')
where your_title_par='x';

--remove any remaning special chars and spaces
update your_table
set link_title=radiofuse.dbo.remove_non_alphanum(link_title)
where your_title_par='x';


--STEP 6
--find matches for parentheticals
--skip first one if you don't have isrc
update your_table
set productid=ttl.productid, match_confidence=100
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null and ttl.isrc=m.link_isrc 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,6)=substring((m.link_artistname collate latin1_general_ci_ai), 1,6) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,6)=substring((m.link_title collate latin1_general_ci_ai), 1,6) and m.productid is null and your_title_par='x';

--skip if you don't have duration
update your_table
set productid=z.productid, match_confidence=100
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,15)=substring((m.link_artistname collate latin1_general_ci_ai), 1,15) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,15)=substring((m.link_title collate latin1_general_ci_ai), 1,15)
and m.duration between ttl.duration+4 and ttl.duration-4
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and your_title_par='x';

--skip if you don't have duration
update your_table
set productid=z.productid, match_confidence=99
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,8)=substring((m.link_artistname collate latin1_general_ci_ai), 1,8) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,8)=substring((m.link_title collate latin1_general_ci_ai), 1,8)
and m.duration between ttl.duration+4 and ttl.duration-4
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and your_title_par='x';

--start here if you have only artist and your_title
update your_table
set productid=z.productid, match_confidence=98
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and ttl.link_artistname collate latin1_general_ci_ai = m.link_artistname collate latin1_general_ci_ai
and ttl.link_title collate latin1_general_ci_ai = m.link_title collate latin1_general_ci_ai
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and your_title_par='x';

update your_table
set productid=z.productid, match_confidence=95
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,12)=substring((m.link_artistname collate latin1_general_ci_ai), 1,12) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,12)=substring((m.link_title collate latin1_general_ci_ai), 1,12)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and your_title_par='x';

update your_table
set productid=z.productid, match_confidence=80
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,8)=substring((m.link_artistname collate latin1_general_ci_ai), 1,8) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,8)=substring((m.link_title collate latin1_general_ci_ai), 1,8)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and your_title_par='x';

update your_table
set productid=z.productid, match_confidence=60
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,6)=substring((m.link_artistname collate latin1_general_ci_ai), 1,6) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,6)=substring((m.link_title collate latin1_general_ci_ai), 1,6)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and your_title_par='x';

update your_table
set productid=z.productid, match_confidence=50
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,6)=substring((m.link_artistname collate latin1_general_ci_ai), 1,6) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,4)=substring((m.link_title collate latin1_general_ci_ai), 1,4)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and your_title_par='x';

update your_table
set productid=z.productid, match_confidence=25
from (
select min(ttl.productid) as productid, m.link_title, m.link_artistname
from radiomodel.dbo.track_link ttl, your_table m
where m.productid is null 
and substring((ttl.link_artistname collate latin1_general_ci_ai), 1,4)=substring((m.link_artistname collate latin1_general_ci_ai), 1,4) 
and substring((ttl.link_title collate latin1_general_ci_ai), 1,4)=substring((m.link_title collate latin1_general_ci_ai), 1,4)
group by m.link_title, m.link_artistname) as z, your_table m2
where z.link_title=m2.link_title and z.link_artistname=m2.link_artistname and m2.productid is null and your_title_par='x';

--STEP 7
--add matched your_artistnames and your_titles
alter table your_table
add matched_your_artistname nvarchar(1024);

alter table your_table
add matched_your_title nvarchar(1024);

update your_table
set matched_your_artistname=ttr.track_your_artistname, matched_your_title=ttr.track_your_title
from your_table m inner join ihrdwh..trackmodel_track_rank ttr on m.productid=ttr.productid;

--view results
select artist, your_title, matched_your_artistname, matched_your_title, productid, match_confidence
from your_table
where productid is not null
order by match_confidence desc;