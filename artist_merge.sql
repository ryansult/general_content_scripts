begin work;
lock table only artist_merge_log nowait;

--INSERT INTO MERGE LOG
insert into artist_merge_log
--put good artistid below
select a.*, 19844 as good_artistid
from amw_artist a
--put bad artistid below
where a.artistid=8577;

--UPDATE ALBUMS
update amw_product
set lastupdated=current_timestamp
from artist_merge_log, amw_track_bundle
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amw_track_bundle.artistid and amw_track_bundle.productid=amw_product.productid;

update amw_track_bundle
set artistid=artist_merge_log.good_artistid, lastupdated=current_timestamp
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amw_track_bundle.artistid;

--UPDATE TRACKS
update amw_product
set lastupdated=current_timestamp
from artist_merge_log, amw_track
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amw_track.artistid and amw_track.productid=amw_product.productid;

update amw_track
set artistid=artist_merge_log.good_artistid
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amw_track.artistid;

--UPDATE ARTIST RELATED
update amw_artist_related
set childartistid=artist_merge_log.good_artistid
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amw_artist_related.childartistid;

delete from amw_artist_related
where artistid in(select am.artistid from artist_merge_log am, amw_artist_related ar where merge_date is null and am.good_artistid=ar.artistid);

update amw_artist_related
set artistid=artist_merge_log.good_artistid
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amw_artist_related.artistid;

--UPDATE AMG ARTIST ASSOCIATIONS
update amgmatch.amw_artist_associations
set artistid=artist_merge_log.good_artistid 
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amgmatch.amw_artist_associations.artistid;

--UPDATE ARTIST IMAGE
update amgmatch.amw_artist_image
set artistid=artist_merge_log.good_artistid 
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amgmatch.amw_artist_image.artistid;

--UPDATE AMGMATCH.ARTIST
update amgmatch.artist
set artistid=artist_merge_log.good_artistid 
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amgmatch.artist.artistid;

--UPDATE ARTIST BIO
insert into artist_merge_bio_data
select am.good_artistid, b.text
from artist_merge_log am, amw_artist_bio b
where b.artistid=am.artistid and am.merge_date is null
union all
select am.good_artistid, b.text
from artist_merge_log am, amw_artist_bio b
where am.merge_date is null and b.artistid=am.good_artistid;

update amw_artist_bio
set text=z.text
from (select ambd.good_artistid, max(text) as text
from artist_merge_bio_data ambd, artist_merge_log am
where am.merge_date is null and am.good_artistid=ambd.good_artistid
group by ambd.good_artistid) as z
where amw_artist_bio.artistid=z.good_artistid;

update amw_artist_bio
set artistid=artist_merge_log.good_artistid 
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amw_artist_bio.artistid and artist_merge_log.good_artistid not in(select artistid from amw_artist_bio);

delete from amw_artist_bio
where artistid in(select am.artistid from artist_merge_log am inner join amw_artist_bio ab on ab.artistid=am.artistid where am.merge_date is null);

--UPDATE ARTIST MAP
update amw_artist_map
set postartistid=artist_merge_log.good_artistid 
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amw_artist_map.postartistid;

update amw_artist_map
set preartistid=artist_merge_log.good_artistid 
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=amw_artist_map.preartistid;

--DELETE FROM PLAYLIST ARTIST
delete from amw_playlist_artist
where artistid in(select am.artistid from artist_merge_log am inner join amw_playlist_artist pa on pa.artistid=am.artistid where am.merge_date is null);

--DELETE FROM ARTIST CATEGORY
delete from amw_artist_category
where artistid in(select am.artistid from artist_merge_log am inner join amw_artist_category ac on ac.artistid=am.artistid where am.merge_date is null);

--UPDATE UNS MATCHED FEED
update reporting.unsmatchedfeed
set artistid=artist_merge_log.good_artistid 
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=reporting.unsmatchedfeed.artistid;

--UPDATE UNS REPORT
update reporting.uns_report
set t_artistid=artist_merge_log.good_artistid 
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=reporting.uns_report.t_artistid;

update reporting.uns_report
set tb_artistid=artist_merge_log.good_artistid 
from artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.artistid=reporting.uns_report.tb_artistid;

--MERGE ARTIST DATA
insert into artist_merge_data
select good_artistid, url, overrideartistid, artistimage, genre_id, vendormetadataid, artistcustomimage, artistimagecustom, name_alias_id, hotness, familiarity, keyname
from artist_merge_log
where merge_date is null
union all
select am.good_artistid, a.url, a.overrideartistid, a.artistimage, a.genre_id, a.vendormetadataid, a.artistcustomimage, a.artistimagecustom, a.name_alias_id, a.hotness, a.familiarity, a.keyname
from artist_merge_log am, amw_artist a
where a.artistid=am.good_artistid and merge_date is null;

update amw_artist
set url=z.url, overrideartistid=z.overrideartistid, artistimage=z.artistimage, genre_id=z.genre_id, vendormetadataid=z.vendormetadataid, artistcustomimage=z.artistcustomimage, artistimagecustom=z.artistimagecustom, name_alias_id=z.name_alias_id, hotness=z.hotness, familiarity=z.familiarity, keyname=z.keyname, lastupdated=current_timestamp
from (select amd.good_artistid, max(amd.url) as url, max(amd.overrideartistid) as overrideartistid, max(amd.artistimage) as artistimage, max(amd.genre_id) as genre_id, max(amd.vendormetadataid) as vendormetadataid, max(amd.artistcustomimage) as artistcustomimage, max(amd.artistimagecustom) as artistimagecustom, max(amd.name_alias_id) as name_alias_id, max(amd.hotness) as hotness, max(amd.familiarity) as familiarity, max(amd.keyname) as keyname
from artist_merge_data amd, amw_artist a, artist_merge_log am
where amd.good_artistid=a.artistid and am.good_artistid=amd.good_artistid and am.merge_date is null
group by amd.good_artistid) as z
where z.good_artistid=amw_artist.artistid;

--UPDATE TRACK NAME ALIAS ID
update amw_track
set name_alias_id=amw_artist.name_alias_id
from amw_artist, artist_merge_log
where artist_merge_log.merge_date is null and artist_merge_log.good_artistid<>6 and amw_track.artistid=artist_merge_log.good_artistid and amw_artist.artistid=artist_merge_log.good_artistid and amw_track.name_alias_id <> amw_artist.name_alias_id;

--DELETE BAD ARTIST FROM AMW_ARTIST
delete from amw_artist
where artistid in(select artistid from artist_merge_log where merge_date is null);

--UPDATE MERGE LOG WITH MERGE DATE
update artist_merge_log
set merge_date = current_timestamp, lastupdated=current_timestamp
where merge_date is null;

commit work;