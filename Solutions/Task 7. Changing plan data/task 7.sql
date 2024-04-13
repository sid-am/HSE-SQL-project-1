create or replace function set_lock (pl_year int, pl_quarter int) returns int
as $$
begin
update plan_status
set status = 'L', modifieddatetime = current_timestamp, author = current_user
where quarterid = (pl_year || '.' || pl_quarter)
    and country in (select country from country_managers where username = current_user)
    and status = 'R';

return 0;
end;
$$ language plpgsql;

CREATE OR REPLACE function remove_lock (pl_year int, pl_quarter int) returns int
as $$
begin
update plan_status
set status = 'R', modifieddatetime = current_timestamp, author = current_user
where quarterid = (pl_year || '.' || pl_quarter)
    and author = current_user
    and status = 'L';

return 0;
end;
$$ language plpgsql;

select set_lock (2014,1);
select remove_lock (2014,1);

--- query for increase
update v_plan_edit
set salesamt=salesamt*1.3
where country in (select country from country_managers where username = current_user);
