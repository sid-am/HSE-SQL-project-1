create table plan_data_history (
    country char(5) not null, quarterid char(6) not null, pcid int not null,
    author varchar(25) not null,
    modified_time timestamp not null,
    salesamt numeric(18, 2) not null,
    salesamt_old numeric(18, 2) not null,
    constraint plan_data_history_pk primary key (country, quarterid, pcid, modified_time, author)
);

create or replace function ch_list () returns trigger
as $$
begin
insert into plan_data_history(country, quarterid, pcid, author, modified_time, salesamt, salesamt_old)
select country, quarterid, pcid, current_user, current_timestamp, new.salesamt, old.salesamt
from plan_data
where salesamt = new.salesamt;

return new;
end $$
language plpgsql;

create trigger chs_trigger
after update on plan_data for each row execute procedure public.ch_list();
