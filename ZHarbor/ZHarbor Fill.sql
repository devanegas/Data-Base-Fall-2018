delete from ZHarborBidHistory;
delete from ZHarborBidLog;
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



select * from ZHarborCustomer;
select * from ZHarborSeller;
select * from ZHarborAuction;
select * from ZHarborBidHistory


