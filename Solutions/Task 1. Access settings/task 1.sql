create user ivan010 with password 'ivan010'; grant planadmin10 to ivan010;
create user sophie010 with password 'sophie010'; grant planmanager10 to sophie010;
create user kirill010 with password 'kirill010'; grant planmanager10 to kirill010;

grant connect on database dma_2023_hw_10 to ivan010, sophie010, kirill010;

grant select on all tables in schema public to planadmin10, planmanager10;
grant select, update, insert, delete on plan_data, plan_status, country_managers to planadmin10;
grant select, update, insert, delete on plan_data to planmanager10;
grant select, update on plan_status, v_plan_edit to planmanager10;
grant select on country_managers, v_plan to planmanager10;

insert into country_managers values ('sophie010','US'), ('sophie010','CA'), ('kirill010','FR'), ('kirill010','GB'), ('kirill010','DE'), ('kirill010','AU');
