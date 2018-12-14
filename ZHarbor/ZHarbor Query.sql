/*
alter table ZHarborAuction
   add constraint statusConstraint CHECK([status]= 'ACTIVE' or [status] = 'ENDED');
 */

 
delete from ZHarborValidBid;
delete from ZHarborMaxBid;
delete from ZHarborAuction;
delete from ZHarborSeller;
delete from ZHarborCustomer;

insert into ZHarborCustomer values (0, 'Diego Vanegas', '150 Main S', '4354354355', 'aaa@aaa.com')
insert into ZHarborCustomer values (1, 'Alex Mickelson', '100 Main N', '4351111111', 'bbb@bbb.com')
insert into ZHarborCustomer values (2, 'Kyler Daybell', '250 Main E', '4354596527', 'ccc@ccc.com')
insert into ZHarborCustomer values (3, 'Kaydon Stubbs', '850 Main NE', '8015699999', 'ddd@ddd.com')
insert into ZHarborCustomer values (4, 'Diego Vanegas', '550 Main W', '8018018010', 'eee@eee.com')

insert into ZHarborSeller values (0, 10) 
insert into ZHarborSeller values (2, 10) 
insert into ZHarborSeller values (4, 10) 

insert into ZHarborAuction values (0, 0, 100, NULL, '2019-11-29 19:15:00.000', NULL, NULL, NULL, NULL, 'Green Chair', 'Its a green chair!', NULL, NULL, NULL);
insert into ZHarborAuction values (1, 0, 250, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Yellow Chair', 'Its a yellow chair!', NULL, NULL, NULL);
insert into ZHarborAuction values (2, 2, 360, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Blue Chair', 'Its a blue chair!', NULL, NULL, NULL);

-----------------UNIT TESTING----------------------

 ----------------ID COUNTER-------------------
drop sequence id_iterator
create sequence id_iterator start with 0 increment by 1;
--------------------------------------------------

--Special Case #1: The user tries to bid a value that is not higher than the starting price
--In this case, we are trying to insert $10
--The starting price is $100

delete from ZHarborValidBid;
delete from ZHarborMaxBid;

EXEC dbo.placeBidAmount @buyer_id = 0, @auction_id = 0, @amount = 10
select * from ZHarborValidBid
select case (select count(*) from ZHarborValidBid h) when 0 then 'PASS' else 'FAIL' END Bid_Lower_Than_Starting_Price;


--Inserting the first valid bid, with a starting price of $100
--The user gets the initial bid since it matches the starting price of $100
delete from ZHarborValidBid;
delete from ZHarborMaxBid;


insert into ZHarborMaxBid values (0, 1, 0, 100); 
select * from ZHarborValidBid
select case (select top 1 h.current_bid from ZHarborValidBid h) when 100 then 'PASS' else 'FAIL' END FirsValidBid;


--Special Case 2: The user tries to raise his own bid
--User raises his own bid from $100 to $110
--Since the program deletes the entry, the remaining bid is the previous one
insert into ZHarborMaxBid values (1, 1, 0, 110); 
select * from ZHarborValidBid
select case (select top 1 h.current_bid from ZHarborValidBid h) when 100 then 'PASS' else 'FAIL' END Fail_to_Raise_own_Bid;


--Special Case 3: Another buyer tries to insert a bid that's lower
--than current bid.
--User inserts $30 but current bid is $100
--Since the program deletes the entry, the remaining bid is the previous one
insert into ZHarborMaxBid values (2, 2, 0, 30); 
select * from ZHarborValidBid
select case (select top 1 h.current_bid from ZHarborValidBid h) when 100 then 'PASS' else 'FAIL' END Bid_Lower_Than_Current_Bid;

--Special Case 4: Another buyer tries to insert a bid that's barely higher
--than the current bid but lower than it would be with the increment .
--User inserts $101 but current bid is in reality $102.50
--TODO ASK
delete from ZHarborValidBid;
delete from ZHarborMaxBid;

insert into ZHarborMaxBid values (0, 1, 0, 100);
insert into ZHarborMaxBid values (1, 2, 0, 101); 

select * from ZHarborValidBid
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 101 then 'PASS' else 'FAIL' END ProxyBidding;
---------------------------------------------------

--Special Case 5: A user tries to insert the same value as the highest bid
-- As a result, the oldest bid stays, and the entry gets deleted
--User with ID = 1 inserts the bid first, so it's the only one that's shown
delete from ZHarborValidBid;
delete from ZHarborMaxBid;

insert into ZHarborMaxBid values (0, 1, 0, 200);
WAITFOR DELAY '00:00:01'
insert into ZHarborMaxBid values (2, 0, 0, 200);

select * from ZHarborMaxBid
select * from ZHarborValidBid
select case (select top 1 h.buyer_id from ZHarborValidBid h order by current_bid desc) when 1 then 'PASS' else 'FAIL' END OldestBidStays;

---------------------------------------------------


--Inserting now some valid bids in the database
delete from ZHarborValidBid;
delete from ZHarborMaxBid;

insert into ZHarborMaxBid values (0, 1, 0, 100); 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 100 then 'PASS' else 'FAIL' END Value1;
insert into ZHarborMaxBid values (1, 2, 0, 105); 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 102.5 then 'PASS' else 'FAIL' END Value2;
insert into ZHarborMaxBid values (2, 1, 0, 110); 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 107.5 then 'PASS' else 'FAIL' END Value3;
WAITFOR DELAY '00:00:01'
insert into ZHarborMaxBid values (3, 3, 0, 250); 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 112.5 then 'PASS' else 'FAIL' END Value4;
WAITFOR DELAY '00:00:01'
insert into ZHarborMaxBid values (4, 2, 0, 259); 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 255 then 'PASS' else 'FAIL' END Value5;

select * from ZHarborMaxBid
select * from ZHarborValidBid
----------------------------------------------


----------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////
-------------------INTEGRATION TESTING STARTS HERE--------------------
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------------------------------------------------------

----->>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<-------


--Special Case #1: The user tries to bid a value that is not higher than the starting price
--In this case, we are trying to insert $10
--The starting price is $100
delete from ZHarborValidBid;
delete from ZHarborMaxBid;

EXEC dbo.placeBidAmount @buyer_id = 0, @auction_id = 0, @amount = 10
select * from ZHarborValidBid
select case (select count(*) from ZHarborValidBid h) when 0 then 'PASS' else 'FAIL' END Bid_Lower_Than_Starting_Price;


--Inserting the first valid bid, with a starting price of $100
--The user gets the initial bid since it matches the starting price of $100
delete from ZHarborValidBid;
delete from ZHarborMaxBid;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
select * from ZHarborValidBid
select case (select top 1 h.current_bid from ZHarborValidBid h) when 100 then 'PASS' else 'FAIL' END FirsValidBid;


--Special Case 2: The user tries to raise his own bid
--User raises his own bid from $100 to $110
--Since the program deletes the entry, the remaining bid is the previous one
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 110 
select * from ZHarborValidBid
select case (select top 1 h.current_bid from ZHarborValidBid h) when 100 then 'PASS' else 'FAIL' END Fail_to_Raise_own_Bid;


--Special Case 3: Another buyer tries to insert a bid that's lower
--than current bid.
--User inserts $30 but current bid is $100
--Since the program deletes the entry, the remaining bid is the previous one
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 30
select * from ZHarborValidBid
select case (select top 1 h.current_bid from ZHarborValidBid h) when 100 then 'PASS' else 'FAIL' END Bid_Lower_Than_Current_Bid;

--Special Case 4: Another buyer tries to insert a bid that's barely higher
--than the current bid but lower than it would be with the increment .
--User inserts $101 but current bid is in reality $102.50
--TODO ASK
delete from ZHarborValidBid;
delete from ZHarborMaxBid;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 101

select * from ZHarborValidBid
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 101 then 'PASS' else 'FAIL' END ProxyBidding;
-----------------


--Inserting now some valid bids in the database and their edgecases
delete from ZHarborValidBid;
delete from ZHarborMaxBid;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 100 then 'PASS' else 'FAIL' END Value1;
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 105
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 102.5 then 'PASS' else 'FAIL' END Value2;
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 110
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 107.5 then 'PASS' else 'FAIL' END Value3;
EXEC dbo.placeBidAmount @buyer_id = 3, @auction_id = 0, @amount = 250
WAITFOR DELAY '00:00:01'
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 112.5 then 'PASS' else 'FAIL' END Value4;
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 259
WAITFOR DELAY '00:00:01'
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 255 then 'PASS' else 'FAIL' END Value5;

select * from ZHarborMaxBid
select * from ZHarborValidBid
----------------------------------------------
--Testing Edge Cases

/*-------------------------------------------------------
|	Current Valid Bid	|	Max Bid	 |	Bid Increment	|
|			0.01		|	0.10	 |		+0.05		|
|			0.15		|	0.99	 |		+0.05		|
|			1.04		|	1.04	 |		+0.25		|
|			1.29		|	1.35	 |		+0.25		|
|			1.60		|	100		 |		+2.50		|
|			102.5		|	150		 |		+2.50		|
|			152.5		|	249.99	 |		+2.50		|
|			252.49		|	300		 |		+2.50		|
|			305.00		|	400		 |		+5.00		|
---------------------------------------------------------*/
--Run this

delete from ZHarborValidBid;
delete from ZHarborMaxBid;
delete from ZHarborAuction;

--Then This
insert into ZHarborAuction values (0, 0, 0.01, NULL, '2019-11-29 19:15:00.000', NULL, NULL, NULL, NULL, 'Green Chair', 'Its a green chair!', NULL, NULL, NULL);

--Then this
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 0.10
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 0.01 then 'PASS' else 'FAIL' END EdgeCase1;
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 0.99
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 0.15 then 'PASS' else 'FAIL' END EdgeCase2;
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 1.04
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 1.04 then 'PASS' else 'FAIL' END EdgeCase3;
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 1.35 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 1.29 then 'PASS' else 'FAIL' END EdgeCase4;
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 1.60 then 'PASS' else 'FAIL' END EdgeCase5;
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 150 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 102.50 then 'PASS' else 'FAIL' END EdgeCase6;
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 249.99 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 152.5 then 'PASS' else 'FAIL' END EdgeCase7;
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 300 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 252.49 then 'PASS' else 'FAIL' END EdgeCase8;
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 400 
select case (select top 1 h.current_bid from ZHarborValidBid h order by current_bid desc) when 305 then 'PASS' else 'FAIL' END EdgeCase9;


---
select * from ZHarborMaxBid
select * from ZHarborValidBid
----------------------------------------------------
--TODO TEST FOR BID PERCENT


---------------------------------------------------
--************************************************-
--Modular Testing: Keeping Track of Different Bids Ond Different Auctions
--PLEASE RUN FILL FILE AGAIN!!!!
--************************************************-


delete from ZHarborValidBid;
delete from ZHarborMaxBid;
delete from ZHarborAuction;
delete from ZHarborSeller;
delete from ZHarborCustomer;

insert into ZHarborCustomer values (0, 'Diego Vanegas', '150 Main S', '4354354355', 'aaa@aaa.com')
insert into ZHarborCustomer values (1, 'Alex Mickelson', '100 Main N', '4351111111', 'bbb@bbb.com')
insert into ZHarborCustomer values (2, 'Kyler Daybell', '250 Main E', '4354596527', 'ccc@ccc.com')
insert into ZHarborCustomer values (3, 'Kaydon Stubbs', '850 Main NE', '8015699999', 'ddd@ddd.com')
insert into ZHarborCustomer values (4, 'Diego Vanegas', '550 Main W', '8018018010', 'eee@eee.com')

insert into ZHarborSeller values (0, 10) 
insert into ZHarborSeller values (2, 10) 
insert into ZHarborSeller values (4, 10) 

insert into ZHarborAuction values (0, 0, 100, NULL, '2019-11-29 19:15:00.000', NULL, NULL, NULL, NULL, 'Green Chair', 'Its a green chair!', NULL, NULL, NULL);
insert into ZHarborAuction values (1, 0, 250, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Yellow Chair', 'Its a yellow chair!', NULL, NULL, NULL);
insert into ZHarborAuction values (2, 2, 360, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Blue Chair', 'Its a blue chair!', NULL, NULL, NULL);

--------------------------------------------------------
--This test will prove that users can bid on different
--auctions, each auction keeping track of its bids
delete from ZHarborValidBid;
delete from ZHarborMaxBid;


EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 300


EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 110
select case (select top 1 h.current_bid from ZHarborValidBid h inner join ZHarborAuction a on (a.id = h.auction_id) where a.id = 0 order by current_bid desc) when 102.5 then 'PASS' else 'FAIL' END DifferentAuction1;
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 400
select case (select top 1 h.current_bid from ZHarborValidBid h inner join ZHarborAuction a on (a.id = h.auction_id) where a.id = 1 order by current_bid desc) when 305 then 'PASS' else 'FAIL' END DifferentAuction2;

select * from ZHarborMaxBid
select * from ZHarborValidBid

---------------------------------------------------------------------
/*--Bidding in Random Auctions with Random Users

EXEC dbo.placeRandom @amount = 100;
*/
-------------------------------------------------------------------------
--Testing different auctions and the stored procedure
--This test will show the effective bids after n-amount of people have inserted their bids
--in different auctions
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 105
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 110
EXEC dbo.placeBidAmount @buyer_id = 3, @auction_id = 0, @amount = 250
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 259
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 300
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 400

select 'These are all the effective bids' as MESSAGE
select * from ZHarborValidBid
select 'Now we divide them in their two groups (Auction 0) and (Auction 1)' as MESSAGE
select * from ZHarborValidBid v where v.auction_id = 0;
select * from ZHarborValidBid v where v.auction_id = 1;
select 'If this test is right, the data above should be the consistent with the one below' as MESSAGE
EXEC dbo.displayEffectiveBid @auction_id = 0
EXEC dbo.displayEffectiveBid @auction_id = 1
EXEC dbo.displayEffectiveBid @auction_id = 2

--------------------------------------------------------------------

--Testing Edge Cases

/*-------------------------------------------------------
|	Current Valid Bid	|	Max Bid	 |	Bid Increment	|
|			100			|	100		 |		+2.50		|
|			102.5		|	110		 |		+2.50		|
|			112.5		|	150		 |		+2.50		|
---------------------------------------------------------*/

--BEFORE
/*---------------------------------------------------------------------------------------
|	Auction ID	|	 Listing Fee	|	Closing Fee 	|  END PRICE |		Status		|
|		0		|		0.5			|		NULL		|	NULL	 |		ACTIVE		|
|		1		|		0.5			|		NULL		|	NULL	 |		ACTIVE		|
-----------------------------------------------------------------------------------------*/

--AFTER
/*---------------------------------------------------------------------------------------
|	Auction ID	|	 Listing Fee	|	Closing Fee 	|  END PRICE |		Status		|
|		0		|		0.5			|		2.025		|	112.5	 |		ENDED		|
|		1		|		0.5			|		NULL		|	NULL	 |		ACTIVE		|
-----------------------------------------------------------------------------------------*/

delete from ZHarborValidBid;
delete from ZHarborMaxBid;
delete from ZHarborAuction;

insert into ZHarborAuction values (0, 0, 100, NULL, CURRENT_TIMESTAMP + '00:00:10', NULL, NULL, NULL, NULL, 'Green Chair', 'Its a green chair!', NULL, NULL, NULL);
insert into ZHarborAuction values (1, 0, 250, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Yellow Chair', 'Its a yellow chair!', NULL, NULL, NULL);
WAITFOR DELAY '00:00:01'

--Insert a couple of rows

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 110
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 150
WAITFOR DELAY '00:00:01'

select * from ZHarborValidBid
select * from ZHarborAuction


GO
EXEC dbo.isValid @auction_id = 0
WAITFOR DELAY '00:00:01'
GO 10


select * from ZHarborValidBid
select * from ZHarborAuction

WAITFOR DELAY '00:00:01'
select case (select top 1 a.[status] from ZHarborValidBid h inner join ZHarborAuction a on (a.id = h.auction_id)) when 'ENDED' then 'PASS' else 'FAIL' END correctStatus;
select case (select top 1 a.end_price from ZHarborValidBid h inner join ZHarborAuction a on (a.id = h.auction_id)) when 112.50 then 'PASS' else 'FAIL' END correctEndPrice;


--Let's add more bids to the already closed Auction
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 200
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 300
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 400

select case (select top 1 b.current_bid from ZHarborValidBid b where b.auction_id = 0 order by current_bid desc) when 112.5 then 'PASS' else 'FAIL' END UpperBoundCorrect;
select case (select top 1 b.current_bid from ZHarborValidBid b where b.auction_id = 0 order by current_bid asc) when 100 then 'PASS' else 'FAIL' END LoweBoundCorrect;

--To prove it, let's add to another auction that's open
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 300
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 400
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 500

select case (select top 1 b.current_bid from ZHarborValidBid b where b.auction_id = 1 order by current_bid desc) when 405 then 'PASS' else 'FAIL' END UpperBoundCorrect;
select case (select top 1 b.current_bid from ZHarborValidBid b where b.auction_id = 1 order by current_bid asc) when 250 then 'PASS' else 'FAIL' END LoweBoundCorrect;

select * from ZHarborValidBid
select * from ZHarborAuction




---------------------------------------------------------------------
--Sellers can create a report of all the active and 
--closed auctions for their account, sorted by auction_starting date

WAITFOR DELAY '00:00:01'
select 'IF THERE ARE TWO REPORTS, THE TEST PASSES'
EXEC dbo.sellerStats @seller_id = 0 
EXEC dbo.sellerStats @seller_id = 1


----------------------------------------------------------------------


--This test will show the functionality of the buyitNow feature
--When two requests are placed, the first one will take place
--
delete from ZHarborValidBid;
delete from ZHarborMaxBid;
delete from ZHarborAuction;

insert into ZHarborAuction values (1, 0, 250, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Yellow Chair', 'Its a Yellow chair!', NULL, NULL, 50);

--EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 500
EXEC dbo.buyItNow @buyer_id = 1, @auction_id = 1 
EXEC dbo.buyItNow @buyer_id = 2, @auction_id = 1 

select * from ZHarborValidBid
select * from ZHarborAuction

EXEC dbo.isValid @auction_id = 1

select * from ZHarborAuction
select case (select top 1 a.seller_id from ZHarborAuction a where a.id = 1) when 0 then 'PASS' else 'FAIL' END FirstComeFirstServe;

----------------------------------------------------------------------


--This test will show the functionality of the buyitNow feature
--When a bid has placed, the buy it now should not work anymore
--
delete from ZHarborValidBid;
delete from ZHarborMaxBid;
delete from ZHarborAuction;

insert into ZHarborAuction values (1, 0, 250, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Yellow Chair', 'Its a Yellow chair!', NULL, NULL, 50);

EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 500
select case (select v.current_bid from ZHarborValidBid v where  v.auction_id = 1) when 250 then 'PASS' else 'FAIL' END BidWasEntered;

select 'TRYING TO USE THE BUY IT NOW AFTER A BID IS PLACED' AS MESSAGE
EXEC dbo.buyItNow @buyer_id = 1, @auction_id = 1 
select case (select top 1 v.current_bid from ZHarborValidBid v where v.auction_id = 1) when 250 then 'PASS' else 'FAIL' END BuyItNowDoesnotWork;


----------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////
--------------------------ALL TESTS END HERE--------------------------
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
---------------------------------------------------------------------

----------------------------------------------------------------------
