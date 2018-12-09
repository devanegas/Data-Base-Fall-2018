delete from ZHarborMaxBid
delete from ZHarborValidBid

declare @seller numeric(18,0)
select @seller = a.seller_id
from ZHarborAuction a
where a.id = 0

EXEC dbo.sellerStats @seller_id = @seller;

select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid

EXEC dbo.placeBidAmount @buyer_id = 40, @auction_id = 0, @amount = 90
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
select * from ZHarborCustomer c where c.id = 40
EXEC dbo.displayEffectiveBid @auction_id = 0

EXEC dbo.placeBidAmount @buyer_id = 80, @auction_id = 0, @amount =90.01
select * from ZHarborAuction a where a.id = 0
select * from ZHarborMaxBid
select * from ZHarborValidBid
select * from ZHarborCustomer c where c.id = 80
EXEC dbo.displayEffectiveBid @auction_id = 0

EXEC dbo.placeBidAmount @buyer_id = 50, @auction_id = 0, @amount = 150
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