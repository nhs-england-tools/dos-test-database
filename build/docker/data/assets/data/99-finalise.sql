create table _metadata (
    label varchar(256) not null primary key,
    value varchar(256) not null
);
insert into _metadata (label, value) values ('created', now());
