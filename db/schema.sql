create table if not exists users
(
	id int auto_increment
		primary key,
	username varchar(256) not null,
	email varchar(256) not null,
	bio_description text null,
	constraint users_email_uindex
		unique (email),
	constraint users_username_uindex
		unique (username)
);

create table if not exists posts
(
	id int auto_increment
		primary key,
	user_id int not null,
	content varchar(1000) null,
	attachment_url text null,
	hashtags_str text null,
	created_at timestamp default CURRENT_TIMESTAMP null,
	updated_at datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
	constraint posts_ibfk_1
		foreign key (user_id) references users (id)
);

create table if not exists comments
(
	id int auto_increment
		primary key,
	user_id int not null,
	post_id int not null,
	content varchar(1000) null,
	attachment_url text null,
	hashtags_str text null,
	created_at timestamp default CURRENT_TIMESTAMP null,
	updated_at datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
	constraint comments_ibfk_1
		foreign key (user_id) references users (id),
	constraint comments_ibfk_2
		foreign key (post_id) references posts (id)
);

create index post_id
	on comments (post_id);

create index user_id
	on comments (user_id);

create index user_id
	on posts (user_id);
