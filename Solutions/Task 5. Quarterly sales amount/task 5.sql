insert into company_sales (cid, salesamt, year, quarter_yr, qr, categoryid, ccls)
select distinct comp.id as cid,
    sum(sd.linetotal) over (partition by to_char(sh.orderdate, 'YYYY.Q'), comp.id, p2.pcid) as salesamt,
    extract (year from sh.orderdate) as year,
    extract (quarter from sh.orderdate) as quarter_yr,
    to_char (sh.orderdate, 'YYYY.Q') as qr,
    p2.pcid as categoryid,
    abc.cls as ccls
from company comp
    join customer c on comp.cname = c.companyname
    join salesorderheader sh on c.customerid = sh.customerid
    join salesorderdetail sd on sh.salesorderid = sd.salesorderid
    join product2 p2 on p2.productid = sd.productid
    join company_abc abc on abc.year = extract(year from sh.orderdate) and abc.cid = comp.id
order by cid;
