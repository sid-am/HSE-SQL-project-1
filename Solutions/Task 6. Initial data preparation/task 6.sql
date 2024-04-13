CREATE OR REPLACE function start_planning (pl_year int, pl_quarter int) returns int
as $$
begin
delete from plan_data where quarterid = (pl_year '.' pl_quarter);
delete from plan_status where quarterid = (pl_year '.' pl_quarter);
insert into plan_status (quarterid, status, modifieddatetime, author, country)
select distinct (pl_year '.' pl_quarter), 'R', current_timestamp, current_user, countrycode from company;

with data as(
    select distinct countrycode, pcid
    from country2 c2, product2 p2
),
amount_1 as (
    select data.countrycode, pcid, year, quarter_yr, sum(salesamt) s
    from data
        join company comp on comp.countrycode = data.countrycode
        join company_sales cs on data.pcid = cs.categoryid and comp.id = cs.cid
    where (ccls = 'A' or ccls = 'B') and (quarter_yr = pl_quarter) and (year in (pl_year - 1, pl_year - 2))
    group by 1, 2, 3, 4
    order by 1, 2, 3, 4
),
amount_2 as (
    select data.countrycode, data.pcid, coalesce(avg(s), 0) average
    from data
        left join amount_1 on data.countrycode = amount_1.countrycode and data.pcid = amount_1.pcid
    group by 1, 2
    order by 1, 2
)

insert into plan_data
select 'N' as versionid,
    amount_2.countrycode as country,
    (pl_year '.' pl_quarter) as quarterid,
    amount_2.pcid as pcid,
    amount_2.average as salesamt
from amount_2;

insert into plan_data
select 'P' as versionid, country, quarterid, pcid, salesamt
from plan_data
where quarterid = (pl_year '.' pl_quarter) and versionid = 'N';

return 0;
end;
$$ language plpgsql;

select start_planning (2014,1);
