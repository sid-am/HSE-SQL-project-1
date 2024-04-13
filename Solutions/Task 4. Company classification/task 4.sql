with S_YI as (
    select distinct extract (year from orderdate) as yi,
        sum(subtotal) over (partition by extract(year from orderdate)) as s
    from salesorderheader sh
    where extract (year from orderdate) in (2012, 2013)
    order by 1
),
UPPER_BOUND as (
    select yi,
        0.8 * s SA,
        0.95 * s SB
    from S_YI
),
ST as (
    select comp.id,
        comp.cname,
        extract (year from sh.orderdate) yi,
        sum(sh.subtotal) st,
        row_number() over(order by extract (year from sh.orderdate), sum(sh.subtotal) desc) rownum
    from company comp
        join customer c on comp.cname = c.companyname
        left join salesorderheader sh on c.customerid = sh.customerid
    where (sh.subtotal is not null) and (extract (year from sh.orderdate) in (2012, 2013))
    group by 1, 3
    order by 3, 4 desc
),
SRT as (
    select id, cname, yi,
        sum(st) over(partition by yi order by rownum) srt
    from ST
),
ANS as (
    select id, cname, SRT.yi, srt,
        case
            when SRT.srt <= UPPER_BOUND.SA then 'A'
            when SRT.srt > UPPER_BOUND.SA and SRT.srt <= UPPER_BOUND.SB then 'B'
            else 'C'
        end as class
    from SRT
        join UPPER_BOUND on SRT.yi = UPPER_BOUND.yi
)
insert into company_abc (cid, salestotal, cls, year)
select ANS.id, ST.st, ANS.class, ANS.yi
from ANS
    join ST on ANS.id = ST.id and ANS.yi = ST.yi
order by 1, 4;
