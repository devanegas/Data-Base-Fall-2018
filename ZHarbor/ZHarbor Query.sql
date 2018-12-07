/*
alter table ZHarborAuction
   add constraint statusConstraint CHECK([status]= 'ACTIVE' or [status] = 'ENDED');
 */

 
 /* FIGURE OUT WHAT I WAS DOING LOL
select b.id, c.name,a.id, i.name , b.bid_max
from ZHarborBidLog b
 inner join ZHarborCustomer c on (c.id = b.buyer_id)
 inner join ZHarborAuction a on (a.id = b.auction_id)
 inner join ZHarborItem i on (i.id = a.item_id);

 */
-----------------UNIT TESTING----------------------

 ----------------ID COUNTER-------------------
drop sequence id_iterator
create sequence id_iterator start with 0 increment by 1;
--------------------------------------------------

--Special Case #1: The user tries to bid a value that is not higher than the starting price
--In this case, we are trying to insert $10
--The starting price is $100

delete from ZHarborBidHistory;
delete from ZHarborBidLog;

EXEC dbo.placeBidAmount @buyer_id = 0, @auction_id = 0, @amount = 10
select * from ZHarborBidHistory
select case (select count(*) from ZHarborBidHistory h) when 0 then 'PASS' else 'FAIL' END Bid_Lower_Than_Starting_Price;


--Inserting the first valid bid, with a starting price of $100
--The user gets the initial bid since it matches the starting price of $100
delete from ZHarborBidHistory;
delete from ZHarborBidLog;

insert into ZHarborBidLog values (0, 1, 0, 100); 
select * from ZHarborBidHistory
select case (select top 1 h.current_bid from ZHarborBidHistory h) when 100 then 'PASS' else 'FAIL' END FirsValidBid;


--Special Case 2: The user tries to raise his own bid
--User raises his own bid from $100 to $110
--Since the program deletes the entry, the remaining bid is the previous one
insert into ZHarborBidLog values (1, 1, 0, 110); 
select * from ZHarborBidHistory
select case (select top 1 h.current_bid from ZHarborBidHistory h) when 100 then 'PASS' else 'FAIL' END Fail_to_Raise_own_Bid;


--Special Case 3: Another buyer tries to insert a bid that's lower
--than current bid.
--User inserts $30 but current bid is $100
--Since the program deletes the entry, the remaining bid is the previous one
insert into ZHarborBidLog values (2, 2, 0, 30); 
select * from ZHarborBidHistory
select case (select top 1 h.current_bid from ZHarborBidHistory h) when 100 then 'PASS' else 'FAIL' END Bid_Lower_Than_Current_Bid;

--Special Case 4: Another buyer tries to insert a bid that's barely higher
--than the current bid but lower than it would be with the increment .
--User inserts $101 but current bid is in reality $102.50
--TODO ASK
delete from ZHarborBidHistory;
delete from ZHarborBidLog;

insert into ZHarborBidLog values (0, 1, 0, 100);
insert into ZHarborBidLog values (1, 2, 0, 101); 

select * from ZHarborBidHistory
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 101 then 'PASS' else 'FAIL' END ProxyBidding;
---------------------------------------------------

--Special Case 5: A user tries to insert the same value as the highest bid
-- As a result, the oldest bid stays, and the entry gets deleted
--User with ID = 1 inserts the bid first, so it's the only one that's shown
delete from ZHarborBidHistory;
delete from ZHarborBidLog;

insert into ZHarborBidLog values (0, 1, 0, 100);
WAITFOR DELAY '00:00:01'
insert into ZHarborBidLog values (1, 2, 0, 100); 

select * from ZHarborBidHistory
select case (select top 1 h.buyer_id from ZHarborBidHistory h order by current_bid desc) when 1 then 'PASS' else 'FAIL' END OldestBidStays;

---------------------------------------------------


--Inserting now some valid bids in the database
delete from ZHarborBidHistory;
delete from ZHarborBidLog;

insert into ZHarborBidLog values (0, 1, 0, 100); 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 100 then 'PASS' else 'FAIL' END Value1;
insert into ZHarborBidLog values (1, 2, 0, 105); 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 102.5 then 'PASS' else 'FAIL' END Value2;
insert into ZHarborBidLog values (2, 1, 0, 110); 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 107.5 then 'PASS' else 'FAIL' END Value3;
insert into ZHarborBidLog values (3, 3, 0, 250); 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 112.5 then 'PASS' else 'FAIL' END Value4;
insert into ZHarborBidLog values (4, 2, 0, 259); 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 255 then 'PASS' else 'FAIL' END Value5;

select * from ZHarborBidLog
select * from ZHarborBidHistory
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
delete from ZHarborBidHistory;
delete from ZHarborBidLog;

EXEC dbo.placeBidAmount @buyer_id = 0, @auction_id = 0, @amount = 10
select * from ZHarborBidHistory
select case (select count(*) from ZHarborBidHistory h) when 0 then 'PASS' else 'FAIL' END Bid_Lower_Than_Starting_Price;


--Inserting the first valid bid, with a starting price of $100
--The user gets the initial bid since it matches the starting price of $100
delete from ZHarborBidHistory;
delete from ZHarborBidLog;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
select * from ZHarborBidHistory
select case (select top 1 h.current_bid from ZHarborBidHistory h) when 100 then 'PASS' else 'FAIL' END FirsValidBid;


--Special Case 2: The user tries to raise his own bid
--User raises his own bid from $100 to $110
--Since the program deletes the entry, the remaining bid is the previous one
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 110 
select * from ZHarborBidHistory
select case (select top 1 h.current_bid from ZHarborBidHistory h) when 100 then 'PASS' else 'FAIL' END Fail_to_Raise_own_Bid;


--Special Case 3: Another buyer tries to insert a bid that's lower
--than current bid.
--User inserts $30 but current bid is $100
--Since the program deletes the entry, the remaining bid is the previous one
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 30
select * from ZHarborBidHistory
select case (select top 1 h.current_bid from ZHarborBidHistory h) when 100 then 'PASS' else 'FAIL' END Bid_Lower_Than_Current_Bid;

--Special Case 4: Another buyer tries to insert a bid that's barely higher
--than the current bid but lower than it would be with the increment .
--User inserts $101 but current bid is in reality $102.50
--TODO ASK
delete from ZHarborBidHistory;
delete from ZHarborBidLog;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 101

select * from ZHarborBidHistory
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 101 then 'PASS' else 'FAIL' END ProxyBidding;
-----------------


--Inserting now some valid bids in the database and their edgecases
delete from ZHarborBidHistory;
delete from ZHarborBidLog;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 100 then 'PASS' else 'FAIL' END Value1;
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 105
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 102.5 then 'PASS' else 'FAIL' END Value2;
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 110
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 107.5 then 'PASS' else 'FAIL' END Value3;
EXEC dbo.placeBidAmount @buyer_id = 3, @auction_id = 0, @amount = 250
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 112.5 then 'PASS' else 'FAIL' END Value4;
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 259
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 255 then 'PASS' else 'FAIL' END Value5;

select * from ZHarborBidLog
select * from ZHarborBidHistory
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

delete from ZHarborBidHistory;
delete from ZHarborBidLog;
delete from ZHarborAuction;

--Then This
insert into ZHarborAuction values (0, 0, 0.01, NULL, '2019-11-29 19:15:00.000', NULL, NULL, NULL, NULL, 'Green Chair', 'Its a green chair!', NULL, NULL, NULL);

--Then this
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 0.10
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 0.01 then 'PASS' else 'FAIL' END EdgeCase1;

EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 0.99
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 0.15 then 'PASS' else 'FAIL' END EdgeCase2;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 1.04
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 1.04 then 'PASS' else 'FAIL' END EdgeCase3;

EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 1.35 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 1.29 then 'PASS' else 'FAIL' END EdgeCase4;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 1.60 then 'PASS' else 'FAIL' END EdgeCase5;

EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 150 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 102.50 then 'PASS' else 'FAIL' END EdgeCase6;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 249.99 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 152.5 then 'PASS' else 'FAIL' END EdgeCase7;

EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 300 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 252.49 then 'PASS' else 'FAIL' END EdgeCase8;

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 400 
select case (select top 1 h.current_bid from ZHarborBidHistory h order by current_bid desc) when 305 then 'PASS' else 'FAIL' END EdgeCase9;


---
select * from ZHarborBidLog
select * from ZHarborBidHistory

---------------------------------------------------
--Modular Testing: Keeping Track of Different Bids Ond Different Auctions
--PLEASE RUN FILL FILE AGAIN!!!!

delete from ZHarborBidHistory;
delete from ZHarborBidLog;


EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 300


EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 110
select case (select top 1 h.current_bid from ZHarborBidHistory h inner join ZHarborAuction a on (a.id = h.auction_id) where a.id = 0 order by current_bid desc) when 102.5 then 'PASS' else 'FAIL' END DifferentAuction1;
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 400
select case (select top 1 h.current_bid from ZHarborBidHistory h inner join ZHarborAuction a on (a.id = h.auction_id) where a.id = 1 order by current_bid desc) when 305 then 'PASS' else 'FAIL' END DifferentAuction2;

select * from ZHarborBidLog
select * from ZHarborBidHistory
---------------------------------------------------------------------


delete from ZHarborBidHistory;
delete from ZHarborBidLog;


--Testing different auctions and the stored procedure
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 105
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 110
EXEC dbo.placeBidAmount @buyer_id = 3, @auction_id = 0, @amount = 250
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 259
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 300
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 400


select * from ZHarborBidLog
select * from ZHarborBidHistory

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

delete from ZHarborBidHistory;
delete from ZHarborBidLog;
delete from ZHarborAuction;

insert into ZHarborAuction values (0, 0, 100, NULL, CURRENT_TIMESTAMP + '00:00:10', NULL, NULL, NULL, NULL, 'Green Chair', 'Its a green chair!', NULL, NULL, NULL);
insert into ZHarborAuction values (1, 0, 250, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Yellow Chair', 'Its a yellow chair!', NULL, NULL, NULL);


--Insert a couple of rows

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 100
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 110
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 150


select * from ZHarborBidHistory
select * from ZHarborAuction


GO
EXEC dbo.isValid @auction_id = 0
WAITFOR DELAY '00:00:01'
GO 10


select * from ZHarborBidHistory
select * from ZHarborAuction

select case (select top 1 a.[status] from ZHarborBidHistory h inner join ZHarborAuction a on (a.id = h.auction_id)) when 'ENDED' then 'PASS' else 'FAIL' END correctStatus;
select case (select top 1 a.end_price from ZHarborBidHistory h inner join ZHarborAuction a on (a.id = h.auction_id)) when 112.50 then 'PASS' else 'FAIL' END correctEndPrice;


--Let's add more bids to the already closed Auction
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 200
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 0, @amount = 300
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 0, @amount = 400

select case (select top 1 b.current_bid from ZHarborBidHistory b where b.auction_id = 0 order by current_bid desc) when 112.5 then 'PASS' else 'FAIL' END UpperBoundCorrect;
select case (select top 1 b.current_bid from ZHarborBidHistory b where b.auction_id = 0 order by current_bid asc) when 100 then 'PASS' else 'FAIL' END LoweBoundCorrect;

--To prove it, let's add to another auction that's open
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 300
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 400
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 500

select case (select top 1 b.current_bid from ZHarborBidHistory b where b.auction_id = 1 order by current_bid desc) when 405 then 'PASS' else 'FAIL' END UpperBoundCorrect;
select case (select top 1 b.current_bid from ZHarborBidHistory b where b.auction_id = 1 order by current_bid asc) when 250 then 'PASS' else 'FAIL' END LoweBoundCorrect;

select * from ZHarborBidHistory
select * from ZHarborAuction




---------------------------------------------------------------------
--Sellers can create a report of all the active and 
--closed auctions for their account, sorted by auction_starting date
--TODO FIX
EXEC dbo.sellerStats @seller_id = 0 
EXEC dbo.sellerStats @seller_id = 1
----------------------------------------------------------------------

delete from ZHarborBidHistory;
delete from ZHarborBidLog;
delete from ZHarborAuction;

insert into ZHarborAuction values (1, 0, 250, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Yellow Chair', 'Its a yellow chair!', NULL, NULL, 50);

EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 500
EXEC dbo.buyItNow @buyer_id = 1, @auction_id = 1 
EXEC dbo.buyItNow @buyer_id = 2, @auction_id = 1 


select * from ZHarborBidHistory
select * from ZHarborAuction


GO
EXEC dbo.isValid @auction_id = 1
WAITFOR DELAY '00:00:01'
GO 10

select * from ZHarborBidHistory
select * from ZHarborAuction

----------------------------------------------------------------------
--////////////////////////////////////////////////////////////////////
--------------------------ALL buyItNow END HERE--------------------------
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
---------------------------------------------------------------------

----------------------------------------------------------------------
