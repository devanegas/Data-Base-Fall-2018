create procedure lab3cursorproc
as
/*
select 
*
from Lab3.F18Purchase p 
left outer join Lab3.F18shipment s on ( s.purchase_id = p.id)
where s.id is null
order by p.id asc
*/
declare @purchase_id numeric(18,0)
declare @customer_id numeric(18,0)
declare @purchase_date date
declare @shipment_id numeric (18,0)
declare @shipper_id numeric (18,0)
declare @inventory_id numeric(18,0)
declare @shipment_date datetime
declare @tracking_number nchar(40)

declare super_cursor cursor for
	select p.id, p.customer_id, p.purchase_date, s.id, 
	s.shipper_id,s.inventory_id, s.shipment_date, s.tracking_number
	from Lab3.F18Purchase p 
		left outer join Lab3.F18shipment s on ( s.purchase_id = p.id)
	where s.id is null

open super_cursor

fetch next from super_cursor
into @purchase_id, @customer_id, @purchase_date, @shipment_id, @shipper_id,
	 @inventory_id, @shipment_date, @tracking_number

while @@FETCH_STATUS = 0
BEGIN
	print '   ' + CAST(@purchase_id as varchar(40))
	
	fetch next from super_cursor
	into @purchase_id, @customer_id, @purchase_date, @shipment_id, @shipper_id,
	 @inventory_id, @shipment_date, @tracking_number
END
close super_cursor
deallocate super_cursor;

GO;
