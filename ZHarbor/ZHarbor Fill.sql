delete from ZHarborValidBid;
delete from ZHarborMaxBid;
delete from ZHarborAuction;
delete from ZHarborSeller;
delete from ZHarborCustomer;


drop sequence fill_id
create sequence fill_id start with 0 increment by 1;
--alter sequence fill_id restart with 0;




-----------FILL CUSTOMER TABLE---------------------------
declare @cnt int = 0;
declare @stop int = 10000;
while @cnt < @stop
begin

insert into ZHarborCustomer
select (next value for fill_id) as ID,
	a.[name] as [Name],
    a.[address] as [Address],
	(select RIGHT('1234567890'+cast(cast(9999999999*rand(checksum(newid())) as bigint) as varchar(30)), 10)),
	(SELECT CONVERT(varchar(50), (LEFT(REPLACE(NEWID(), '-', ''), 7)+ '@zharbor.com' )))
from (select top 1  * from [diego].[Lab3].[F18customer] order by newid() ) a
set @cnt = @cnt +1;
end;

--------------Generate Sellers------------------------------
alter sequence fill_id restart with 0;
set @cnt = 0;
set @stop = 500;
while @cnt < @stop
begin
insert into ZHarborSeller values
	((select c.id from ZHarborCustomer c where c.id = @cnt), (select FLOOR(RAND()*(1000000000-1+1))+1))
set @cnt = @cnt +1;
end;

-------------Generate Auctions-------------------------------------------------
alter sequence fill_id restart with 0;
set @cnt = 0;
set @stop = 2000;
while @cnt < @stop
begin
if(@cnt%5  = 0)
	BEGIN
	insert into ZHarborAuction 
	select(next value for fill_id),
		(select top 1 s.customer_id from ZHarborSeller s order by newid()),
		(select CONVERT(money, a.retailprice)),
		NULL,
		CURRENT_TIMESTAMP + '10:00:00',
		'ACTIVE',
		NULL,
		NULL,
		NULL,
		a.name,
		(select RTRIM(CONVERT(varchar(max), a.description))),
		NULL,
		NULL,
		(select CONVERT(money, a.retailprice + 25))
	from (select top 1 * from [Fall2018].[Lab3].[F18merchandise] order by newid()) a
	set @cnt = @cnt +1;
	END;
else
	BEGIN
	insert into ZHarborAuction 
	select(next value for fill_id),
		(select top 1 s.customer_id from ZHarborSeller s order by newid()),
		(select CONVERT(money, a.retailprice)),
		NULL,
		CURRENT_TIMESTAMP + '10:00:00',
		'ACTIVE',
		NULL,
		NULL,
		NULL,
		a.name,
		(select RTRIM(CONVERT(varchar(max), a.description))),
		NULL,
		NULL,
		NULL
	from (select top 1 * from [Fall2018].[Lab3].[F18merchandise] order by newid()) a
	set @cnt = @cnt +1;
	END
end;

select count(*) as NumberOfCustomers from ZHarborCustomer;
select count(*) as NumberOfSellers from ZHarborSeller;
select count(*) as NumberOfAuctions from ZHarborAuction;

select * from ZHarborAuction;

select s.customer_id, c.[name], s.tax_id
from ZHarborSeller s 
	inner join ZHarborCustomer c on (c.id = s.customer_id);




