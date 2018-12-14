--Select the auction with ID=0
delete from ZHarborMaxBid
delete from ZHarborValidBid
declare @seller numeric(18,0)
select @seller = a.seller_id
from ZHarborAuction a
where a.id = 0
EXEC dbo.sellerStats @seller_id = @seller;
-----------------------------------------
--INITIAL STATUS
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

--BIDDING 100 AT FIRST / SHOULD OBTAIN INITIAL BID
EXEC dbo.placeBidAmount @buyer_id = 45, @auction_id = 0, @amount = 100
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
select * from ZHarborCustomer c where c.id = 40
EXEC dbo.displayEffectiveBid @auction_id = 0


--BIDS LESS THAN THE MAX BID, BUT BECAUSE OF PROXY
--BIDDING, THE CURRENT VALID BID GOES UP TO 100
EXEC dbo.placeBidAmount @buyer_id = 80, @auction_id = 0, @amount = 99
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
select * from ZHarborCustomer c where c.id = 80
EXEC dbo.displayEffectiveBid @auction_id = 0

--BIDS ONE CENT MORE, THE CURRENT VALID BID
--IS NOW 100.01
EXEC dbo.placeBidAmount @buyer_id = 50, @auction_id = 0, @amount = 100.01
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
select * from ZHarborCustomer c where c.id = 50
EXEC dbo.displayEffectiveBid @auction_id = 0

-----------------------------------------------------------------------
--Reports

select a.seller_id from ZHarborAuction a where a.id = 0
EXEC dbo.openAuctions
EXEC dbo.displayEffectiveBid 0
EXEC dbo.myBids @buyer_id = 45


--Auction "Closes"
select * from ZHarborAuction a where a.id = 0
EXEC dbo.cancelAuction 0
EXEC dbo.sellerStats 24
EXEC dbo.sellerFees 2
EXEC dbo.auctionsWon @buyer_id = 45


---------------------------------------------------------------
-->>>>>>>>>>>>>>>>  RUN LIGHT FILL AGAIN   <<<<<<<<<<<<<<<<<<<<<
--------------------------------------------------------

--Select the auction with ID=0
delete from ZHarborMaxBid
delete from ZHarborValidBid
declare @seller numeric(18,0)
select @seller = a.seller_id
from ZHarborAuction a
where a.id = 0
EXEC dbo.sellerStats @seller_id = @seller;
-----------------------------------------
--INITIAL STATUS
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

--BUYING THE BUYITNOW PRICE
EXEC dbo.buyItNow @buyer_id = 80, @auction_id = 0
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
select * from ZHarborCustomer c where c.id = 80
EXEC dbo.isValid @auction_id = 0


--TRYING TO BID AGAIN (SHOULDN'T WORK)
EXEC dbo.placeBidAmount @buyer_id = 70, @auction_id = 0, @amount = 1000
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
EXEC dbo.displayEffectiveBid @auction_id = 0


-----------------------------------------------------------------------
--Reports

select a.seller_id from ZHarborAuction a where a.id = 0
EXEC dbo.openAuctions
EXEC dbo.sellerFees 24
EXEC dbo.sellerStats 24

EXEC dbo.displayEffectiveBid @auction_id = 0


--User wants to know his/her status"
select * from ZHarborAuction a where a.id = 0
EXEC dbo.auctionsWon @buyer_id = 80
------------------------------------------------------------------------
--Proveable
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

insert into ZHarborAuction values (0, 0, 99, NULL, '2019-11-29 19:15:00.000', NULL, NULL, NULL, NULL, 'Green Chair', 'Its a green chair!', NULL, NULL, NULL);
insert into ZHarborAuction values (1, 0, 10, NULL, '2019-11-29 20:59:00.000', NULL, NULL, NULL, NULL, 'Yellow Chair', 'Its a yellow chair!', NULL, NULL, NULL);

EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 20
WAITFOR DELAY '00:00:00:10'
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 22
WAITFOR DELAY '00:00:00:10'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 25
WAITFOR DELAY '00:00:00:10'
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 30
WAITFOR DELAY '00:00:00:10'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 33
WAITFOR DELAY '00:00:00:10'
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 40
WAITFOR DELAY '00:00:00:10'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 39.50

EXEC dbo.cancelAuction 1
select * from ZHarborAuction a where a.id = 1
select * from ZHarborCustomer c where c.id = 2

WAITFOR DELAY '00:00:00:10'
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 40.01

select * from ZHarborAuction
select * from ZHarborValidBid
select * from ZHarborMaxBid


EXEC dbo.auctionsWon @buyer_id = 1
EXEC dbo.myBids @buyer_id = 1
EXEC dbo.openAuctions
EXEC dbo.sellerStats 0

