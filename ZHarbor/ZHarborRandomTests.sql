delete from ZHarborMaxBid
delete from ZHarborValidBid
declare @seller numeric(18,0)
select @seller = a.seller_id
from ZHarborAuction a
where a.id = 0
EXEC dbo.sellerStats @seller_id = @seller;
-----------------------------------------
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

EXEC dbo.placeBidAmount @buyer_id = 45, @auction_id = 0, @amount = 90
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
select * from ZHarborCustomer c where c.id = 40
EXEC dbo.displayEffectiveBid @auction_id = 0

EXEC dbo.placeBidAmount @buyer_id = 80, @auction_id = 0, @amount = 89
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
select * from ZHarborCustomer c where c.id = 80
EXEC dbo.displayEffectiveBid @auction_id = 0

EXEC dbo.placeBidAmount @buyer_id = 50, @auction_id = 0, @amount = 90.01
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
select * from ZHarborCustomer c where c.id = 50
EXEC dbo.displayEffectiveBid @auction_id = 0


EXEC dbo.displayEffectiveBid @auction_id = 0
EXEC dbo.cancelAuction @auction_id = 0

EXEC dbo.placeBidAmount @buyer_id = 50, @auction_id = 0, @amount = 1000
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

------------------------------------------------------------------------
delete from ZHarborMaxBid
delete from ZHarborValidBid

EXEC dbo.sellerStats @seller_id = 31;

select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

EXEC dbo.placeBidAmount @buyer_id = 40, @auction_id = 0, @amount =100
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

EXEC dbo.placeBidAmount @buyer_id = 80, @auction_id = 0, @amount =100
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

EXEC dbo.placeBidAmount @buyer_id = 50, @auction_id = 0, @amount = 150
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

EXEC dbo.placeBidAmount @buyer_id = 55, @auction_id = 0, @amount = 180
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

EXEC dbo.buyItNow @buyer_id = 88, @auction_id = 0
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid


EXEC dbo.displayEffectiveBid @auction_id = 0

EXEC dbo.placeBidAmount @buyer_id = 50, @auction_id = 0, @amount = 1000
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

select * from ZHarborCustomer c where c.id = 80 
EXEC dbo.displayEffectiveBid @auction_id = 0

EXEC dbo.sellerStats @seller_id = 8;
select * from ZHarborAuction a where a.id = 0

-----------------------------------
EXEC dbo.buyItNow @buyer_id = 80, @auction_id = 0
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

EXEC dbo.isValid @auction_id = 0



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
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 22
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 25
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 30
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 33
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 40
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 1, @auction_id = 1, @amount = 39.50
WAITFOR DELAY '00:00:01'
EXEC dbo.placeBidAmount @buyer_id = 2, @auction_id = 1, @amount = 40.01

select * from ZHarborAuction
select * from ZHarborValidBid
select * from ZHarborMaxBid


EXEC dbo.sellerStats @seller_id = 0;
EXEC dbo.cancelAuction @auction_id = 0
EXEC dbo.cancelAuction @auction_id = 1
select * from ZHarborAuction

EXEC dbo.sellerFees @seller_id = 0
EXEC dbo.auctionsWon @buyer_id = 1
EXEC dbo.myBids @buyer_id = 1
EXEC dbo.openAuctions
EXEC dbo.sellerStats 0


/*
select a.id as Auction_ID, a.item_name, a.starting_time, a.end_time, a.starting_price, (CASE WHEN count(v.current_bid) = 0 THEN NULL ELSE v.current_bid END)
from ZHarborAuction a
inner join ZHarborValidBid v on (v.auction_id = a.id)
where a.status = 'ACTIVE'
group by a.id, a.item_name, a.item_name, a.starting_time, a.end_time, a.starting_price, v.current_bid
*/

