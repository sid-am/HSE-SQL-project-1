create materialized view mv_plan_fact_2014_q1 as
with data as (select distinct '2014.1' as quarter, countrycode as country, pcid, pcname from country2, product2),
actual as (
    select comp.countrycode country,
        pr2.pcid,
        pr2.pcname,
        to_char(sh.orderdate, 'YYYY.Q') as qr,
        sum(linetotal) as actual_s
    from salesorderdetail sd
        join salesorderheader sh on sh.salesorderid = sd.salesorderid
        join customer c on c.customerid = sh.customerid
        join company comp on comp.cname = c.companyname
        join product2 pr2 on pr2.productid = sd.productid
    where comp.id in (
        select distinct cid
        from company_abc compabc
            join plan_data pd on compabc."year" = left(pd.quarterid, 4)::integer - 1
        where cls in ('A', 'B')
    )
    group by 1, 2, 3, 4
    order by 1, 2, 4
),
plan as (
    select country, pcid, quarterid as qr, salesamt as plan_s
    from plan_data pd
    where versionid = 'A'
),
t as (
    select data.quarter, data.country, data.pcname, plan_s, actual_s
    from data
        left join actual on actual.country = data.country
            and actual.pcid = data.pcid
            and actual.qr = data.quarter
        left join plan on plan.country = data.country
            and plan.pcid = data.pcid
            and plan.qr = data.quarter
    order by 2, 3
)

select quarter,
    country,
    pcname,
    case
        when (plan_s is null) or (plan_s = 0) then null
        else plan_s - actual_s
    end as dev,
    case
        when (plan_s is null) or (plan_s = 0) then null
        else round((plan_s - actual_s) / plan_s * 100)||'%'
    end as "dev, %"
from t
