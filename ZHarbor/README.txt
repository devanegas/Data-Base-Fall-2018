Functions and Procedures Available:

Functions:
whichListing(@starting_price money)
whichIncrement(@current_price money)
whichClosing(@closing_price money)


Procedures
placeBidAmount @buyer_id numeric(18,0), @auction_id numeric(18,0), @amount money
placeBidPercent @buyer_id numeric(18,0), @auction_id numeric(18,0), @percent money
displayEffectiveBid @auction_id numeric(18,0)
isValid @auction_id numeric(18,0)
sellerStats @seller_id numeric (18,0)
cancelAuction @auction_id numeric (18,0)
buyItNow @buyer_id numeric(18,0), @auction_id numeric(18,0)