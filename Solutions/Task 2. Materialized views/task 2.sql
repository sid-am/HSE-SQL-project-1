create materialized view product2 as
select cat.productcategoryid as pcid,
    p.productid as productid,
    cat.name as pcname,
    p.name as pname
from product p
    join productsubcategory sub on p.productsubcategoryid = sub.productsubcategoryid
    join productcategory cat on sub.productcategoryid = cat.productcategoryid;

create materialized view country2 as
select distinct a.countryregioncode as countrycode
from address a
    join customeraddress adr on a.addressid = adr.addressid
where adr.addresstype = 'Main Office';

grant select on product2, country2 to planadmin10, planmanager10;
