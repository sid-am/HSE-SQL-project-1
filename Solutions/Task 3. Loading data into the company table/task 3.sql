insert into company (cname, countrycode, city)
select distinct c.companyname,
    a.countryregioncode,
    a.city
from customer c
    join customeraddress adr on c.customerid = adr.customerid
    join address a on a.addressid = adr.addressid
where adr.addresstype = 'Main Office';