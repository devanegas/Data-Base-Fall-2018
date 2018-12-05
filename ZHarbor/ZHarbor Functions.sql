drop sequence id_iterator
create sequence id_iterator start with 0 increment by 1
---------------------<><><><><><><><><><><>-----------------------------
---------------------<>Function Creation <>---------------------------
---------------------<><><><><><><><><><><>-----------------------------

drop function whichListing
GO
create function whichListing(@starting_price money)
	returns money
	as
begin
	declare @listing_fee money;
		if(@starting_price < 10) set @listing_fee = 0.05
		else if (@starting_price >= 10 and @starting_price <100) set @listing_fee = 0.25
		else if (@starting_price >= 100 and @starting_price <1000)  set @listing_fee = 0.50
		else if (@starting_price >= 1000) set @listing_fee = 1
		else set @listing_fee = 0
	
	return @listing_fee;
end;
GO


---------------/*Test Case*/------------------
/*
DECLARE @cnt money = 0;

WHILE @cnt < 2000
BEGIN
   select @cnt as Starting_Price, [dbo].whichListing(@cnt) as Listing
   SET @cnt = @cnt+10;
END;
*/
--------------/*End Test Case*/---------------

drop function whichIncrement
GO
create function whichIncrement(@current_price money)
returns money
as 
begin
	declare @bid_increment money;

	/*
	select @current_price = a.current_bid
		from [dbo].ZHarborBidHistory a
		where a.id = @auction_id
	*/

		if(@current_price < 0.99) set @bid_increment = 0.05
		else if (@current_price >= 1 and @current_price < 5) set @bid_increment = 0.25
		else if (@current_price >= 5 and @current_price < 25) set @bid_increment = 0.50
		else if (@current_price >= 25 and @current_price < 100) set @bid_increment = 1
		else if (@current_price >= 100 and @current_price < 250) set @bid_increment = 2.50
		else if (@current_price >= 250 and @current_price < 500) set @bid_increment = 5
		else if (@current_price >= 500 and @current_price < 1000) set @bid_increment = 10
		else if (@current_price >= 1000 and @current_price < 2500) set @bid_increment = 25
		else if (@current_price >= 2500 and @current_price < 5000) set @bid_increment = 50
		else if (@current_price >= 5000) set @bid_increment = 100
		else set @current_price = 0
	
	return @bid_increment;
end;
GO

---------------/*Test Case*/------------------
/*
DECLARE @cnt money = 0;

WHILE @cnt < 200
BEGIN
   select @cnt as Current_Price, [dbo].bid_test(@cnt) as Bid_Increment
   SET @cnt = @cnt+10;
END;
*/
--------------/*End Test Case*/----------------

drop function whichClosing

GO
create function whichClosing(@closing_price money)
returns money
as
begin

declare @closing_fee money;

if(@closing_price = 0) set @closing_fee = 0
		else if (@closing_price > 0 and @closing_price < 10) set @closing_fee = (@closing_price *0.02)
		else if (@closing_price >= 10 and @closing_price < 50) set @closing_fee = (@closing_price *0.019)
		else if (@closing_price >= 50 and @closing_price < 1000) set @closing_fee = (@closing_price *0.018)
		else if (@closing_price >= 1000 and @closing_price < 20000) set @closing_fee = (@closing_price *0.015)
		else set @closing_price = (@closing_price *0.012);

		return @closing_fee;

end;
GO

---------------/*Test Case*/------------------
/*
DECLARE @cnt money = 0;

WHILE @cnt < 200
BEGIN
   select @cnt as Closing_Price, dbo.whichClosing(@cnt) as Closing_Fee
   SET @cnt = @cnt+10;
END;
*/
--------------/*End Test Case*/----------------



---------------------<><><><><><><><><><>-----------------------------
---------------------<>Trigger Creation<>---------------------------
---------------------<><><><><><><><><><>-----------------------------

drop trigger Bidlog

GO
create trigger Bidlog on ZHarborBidLog
after insert as
BEGIN

declare @inserted_id numeric (18,0)

	declare @bid_Top money
	declare @bid_Second money
	declare @auction numeric (18,0)
	declare @current_valid_bid money
	declare @inserted_bid money
	declare @first money
	declare @previous_id numeric (18,0)
	declare @actual_id numeric (18,0)
	declare @end_time datetime
	declare @status varchar(50)

	select @auction = i.auction_id
			from inserted i;

	select top 1 @previous_id = h.buyer_id
	from ZHarborBidHistory h
	where h.auction_id = @auction
	order by date desc

	select @actual_id = i.buyer_id
	from inserted i

	select @first = a.starting_price from ZHarborAuction a where a.id = @auction

	select top 1 @current_valid_bid = b.current_bid
	from ZHarborAuction a
			inner join ZHarborBidHistory b on (b.auction_id = a.id)
			where b.auction_id = @auction
			order by current_bid desc

	select @end_time = a.end_time, @status = a.status from ZHarborAuction a where a.id = @auction


	declare bid_Cursor cursor for 
		select top 2 b.bid_max from ZHarborBidLog b
		where b.auction_id = @auction
		order by bid_max desc;

	open bid_Cursor
	fetch next from bid_Cursor
	into @bid_Top

	fetch next from bid_Cursor
	into @bid_Second


	close bid_cursor
	deallocate bid_cursor;

	select @inserted_bid = i.bid_max
	from inserted i


	if(CURRENT_TIMESTAMP < @end_time and @status = 'ACTIVE')
	BEGIN
		if (@bid_Second is NULL and @inserted_bid >= @first)
		BEGIN
		declare @buyer_id numeric(18,0)
		declare @starting_price money
		declare @auction_id numeric (18,0)
		--declare @id numeric (18,0)

		select @buyer_id = i.buyer_id
			from inserted i

		select @auction_id = i.auction_id
			from inserted i

		select @starting_price = a.starting_price
			from inserted i
			inner join ZHarborAuction a on (a.id = i.auction_id)

		--set @id = next value for id_iterator

			insert into ZHarborBidHistory 
			values(next value for id_iterator, @auction_id, @buyer_id, @starting_price , CURRENT_TIMESTAMP)
		END
		else if(@inserted_bid > @current_valid_bid and @actual_id != @previous_id)
		BEGIN
			declare @max_bid money
			declare @current_bid money
			declare @current money

			
			select @max_bid = i.bid_max
			from inserted i

		--Select the top current bid from the history
				select top 1 @current = b.current_bid
				from ZHarborAuction a
				inner join ZHarborBidHistory b on (b.auction_id = a.id)
				where b.auction_id = @auction
				order by current_bid desc

			if(@max_bid > @bid_Second+[dbo].whichIncrement(@current))
				BEGIN

				--set @id = next value for id_iterator

				select @buyer_id = i.buyer_id
				from inserted i

				select @auction_id = i.auction_id
				from inserted i

				set @current_bid = @bid_Second + [dbo].whichIncrement(@bid_Second)

				insert into ZHarborBidHistory values
				(next value for id_iterator, @auction_id, @buyer_id, @current_bid, CURRENT_TIMESTAMP)

				END

			else --TODO: Proxy Bidding.
				BEGIN

					select @buyer_id = i.buyer_id
					from inserted i

					select @auction_id = i.auction_id
					from inserted i

					select @current_bid = i.bid_max
					from inserted i

					insert into ZHarborBidHistory 
					values(next value for id_iterator,@auction_id, @buyer_id, @current_bid , CURRENT_TIMESTAMP)
					/*select @inserted_id = i.id from inserted i
					delete from ZHarborBidLog where id = @inserted_id
					*/
				END

		END
		else
				BEGIN
				
				select @inserted_id = i.id from inserted i
				delete from ZHarborBidLog where id = @inserted_id
				END
					--//TODO: Check dates
		END
	
	else
	BEGIN 
		select @inserted_id = i.id from inserted i
		delete from ZHarborBidLog where id = @inserted_id
	END
END
GO

---------------------------------------------------

drop trigger createdAuction


GO
create trigger createdAuction on ZHarborAuction
after insert as
BEGIN
	declare @auction_id numeric (18,0)
	declare @closing_price money
	declare @listing_price money
	declare @fee money
	declare @buyItNowPrice money

	select @auction_id = i.id
	from inserted i
	
	select @buyItNowPrice = i.buyNow
	from inserted i

	select @listing_price = dbo.whichListing(i.starting_price)
	from inserted i
	
	

	UPDATE ZHarborAuction
	SET starting_time = CURRENT_TIMESTAMP, [status] = 'ACTIVE', listing_fee = @listing_price
	WHERE id = @auction_id;

END
GO


---------------------<><><><><><><><><><><>---------------------------
---------------------<>Procedure Creation<>---------------------------
---------------------<><><><><><><><><><><>---------------------------
drop procedure placeBidAmount
GO
create procedure placeBidAmount @buyer_id numeric(18,0), @auction_id numeric(18,0), @amount money
as
BEGIN
	declare @id numeric(18, 0)
	set @id = next value for id_iterator  --ID ITERATOR MIGHT NEED TO BE REFACTORED
	
	insert into dbo.ZHarborBidLog values (@id, @buyer_id,  @auction_id, @amount);
END
GO

--------------------------------------------------
drop procedure placeBidPercent

GO
create procedure placeBidPercent @buyer_id numeric(18,0), @auction_id numeric(18,0), @percent money
as
BEGIN
	declare @id numeric(18, 0)
	set @id = next value for id_iterator

	declare @amount money

	select top 1 @amount =  h.current_bid
	from dbo.ZHarborBidHistory h
	inner join dbo.ZHarborBidLog l on (l.auction_id = h.auction_id)
	where l.auction_id = @auction_id
	order by current_bid desc

	set @amount = @amount * (1 + @percent)

	insert into dbo.ZHarborBidLog values (@id, @buyer_id,  @auction_id, @amount);
END
GO

---------------------------------------------------------------------

drop procedure displayEffectiveBid 

GO
create procedure displayEffectiveBid @auction_id numeric(18,0)
as
BEGIN
	select c.name, h.current_bid
	from dbo.ZHarborBidHistory h
	inner join dbo.ZHarborAuction a on (a.id = h.auction_id)
	inner join dbo.ZHarborCustomer c on (c.id = h.buyer_id)
	where h.auction_id = @auction_id
	order by current_bid desc
END
GO
-----------------------------------------------------------------------
drop procedure isValid
GO
create procedure isValid @auction_id numeric(18,0)
as
BEGIN
	declare @status varchar(50)
	declare @end_time datetime
	declare @winner varchar (30)
	declare @winner_id numeric (18,0)

	select @status = a.status
	from ZHarborAuction a
	where id = @auction_id

	select @end_time = a.end_time, @status = a.status
	from ZHarborAuction a
	where a.id = @auction_id
		
		if(CURRENT_TIMESTAMP < @end_time)
			print ('STILL GOING')
		else if (@status = 'ACTIVE')
			BEGIN

			declare @end_price money
			declare @closing_fee money


			select top 1 @end_price = h.current_bid
			from ZHarborBidHistory h
			where h.auction_id = @auction_id
			order by current_bid desc

			set @closing_fee = dbo.whichClosing(@end_price)


			select top 1 @winner_id = c.id
			from ZHarborBidHistory h 
			inner join ZHarborAuction a on (a.id = h.auction_id)
			inner join ZHarborBidLog b on (b.auction_id = a.id)
			inner join ZHarborCustomer c on (c.id = b.buyer_id)
			where h.auction_id = @auction_id
			order by current_bid desc

			select top 1 @winner = c.name
			from ZHarborBidHistory h 
			inner join ZHarborAuction a on (a.id = h.auction_id)
			inner join ZHarborBidLog b on (b.auction_id = a.id)
			inner join ZHarborCustomer c on (c.id = b.buyer_id)
			where h.auction_id = @auction_id
			order by current_bid desc


			UPDATE ZHarborAuction
				SET closing_fee = @closing_fee, winner_id = @winner_id, winner_name = @winner
				WHERE id = @auction_id;

			UPDATE ZHarborAuction
				SET end_price = @end_price, [status] = 'ENDED'
				WHERE id = @auction_id;

				print('AUCTION JUST ENDED, THE WINNER IS')
				print(@winner)
				print('AND HE PAYS:')
				print(@end_price)

			END
		else
			print ('AUCTION ALREADY ENDED')
END
GO



drop procedure sellerStats

GO
create procedure sellerStats @seller_id numeric (18,0)
as
BEGIN
/*
	declare @end_time datetime;

	select @end_time = a.end_time 
	from ZHarborAuction a
	where a.seller_id = @seller_id
	 */
	select a.id, a.item_name, a.starting_time, (select datediff(MINUTE, GETDATE(), a.end_time )) as Remainig_Minutes, a.status, a.end_price, a.winner_name
	from ZHarborAuction a
	where a.seller_id = @seller_id
	order by starting_time desc
END
GO

---------------------


drop procedure buyItNow
GO
create procedure buyItNow @buyer_id numeric(18,0), @auction_id numeric(18,0)
as
BEGIN
	declare @buyItNowPrice money
	declare @status varchar(30)

	select @buyItNowPrice = a.buyNow
	from ZHarborAuction a
	where a.id = @auction_id

	select @status = a.[status]
	from ZHarborAuction a
	where a.id = @auction_id


	if(@buyItNowPrice != NULL and @status = 'ACTIVE')
		BEGIN
			insert into ZHarborBidHistory values (next value for id_iterator, @auction_id,  @buyer_id, @buyItNowPrice, CURRENT_TIMESTAMP);

			UPDATE ZHarborAuction
				SET end_price = @buyItNowPrice, [status] = 'ENDED'
				WHERE id = @auction_id;

		END
	else
		--DO NOTHING
		print('Sorry, Invalid Action')
	
END
GO

