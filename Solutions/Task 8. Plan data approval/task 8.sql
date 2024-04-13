create or replace function accept_plan (pl_year int, pl_quarter int, "user" name, pwd varchar) returns int
as $$
begin
insert into plan_data (versionid, country, quarterid, pcid, salesamt)
select 'A', pd.country, pd.quarterid, pcid, salesamt
from plan_data pd
    join plan_status ps on ps.country = pd.country and ps.quarterid = pd.quarterid
    join country_managers cm on cm.country = pd.country
where pd.quarterid = (pl_year || '.' || pl_quarter)
    and versionid = 'P'
    and status = 'R'
    and pd.country in (select country from country_managers cm where cm.username = "user")
    and pwd = case
when "user" = 'ivan010' then 'ivan010'
when "user" = 'kirill010' then 'kirill010'
when "user" = 'sophie010' then 'sophie010'
end;

update plan_status
set status = 'A', author = current_user, modifieddatetime = current_timestamp
where quarterid = (pl_year || '.' || pl_quarter)
    and status = 'R'
    and country in (select country from country_managers cm where cm.username = "user") and pwd = case
when "user" = 'ivan010' then 'ivan010'
when "user" = 'kirill010' then 'kirill010'
when "user" = 'sophie010' then 'sophie010'
end;

return 0;
end;
$$ language plpgsql;

select accept_plan(2014, 1, 'kirill010', 'kirill010');
select accept_plan(2014, 1, 'sophie010', 'sophie010');
