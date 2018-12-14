Functions and Procedures Available:

Functions:
whichListing(@starting_price money)
whichIncrement(@current_price money)
whichClosing(@closing_price money)


Procedures
placeBidAmount @buyer_id numeric(18,0), @auction_id numeric(18,0), @amount money
cancelAuction @auction_id numeric (18,0)
placeBidPercent @buyer_id numeric(18,0), @auction_id numeric(18,0), @percent money
displayEffectiveBid @auction_id numeric(18,0)
isValid @auction_id numeric(18,0)
sellerStats @seller_id numeric (18,0) //Not Relevant
buyItNow @buyer_id numeric(18,0), @auction_id numeric(18,0)
sellerFees @seller_id(18,0)
auctionsWon @buyer_id (18,0)
myBids @buyer_id (18,0)
openAuctions -- No parameters


Triggers:
Bidlog on ZHarborMaxBid insert
CreatedAuction on ZHarborAuction insert
