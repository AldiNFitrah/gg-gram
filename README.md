# GG-Gram
Backend Service for an internal social media that used in a certain company.
Built with Ruby and Sinatra Framework

<br/>

## Scope
### In-Scope
1. User
    - Can be created
    - Fields:
        - username
        - email
        - bio description

2. Post
    - Can be created
    - Affiliated to a user
    - May contain hashtags
    - May contain attachment which is a picture, video, or other file
    - Can be filtered by a hashtag (case-insensitive)
    - The hashtags will be counted in the trending hashtags board
    - Fields:
        - user_id
        - content (max 1000 characters)
        - attachment

3. Comment
    - Can be created
    - Affiliated to a user and a post
    - May contain hashtags (case-insensitive)
    - May contain attachment which is a picture, video, or other file
    - Can be filtered by a hashtag
    - The hashtags will be counted in the trending hashtags board
    - Fields:
        - user_id
        - post_id
        - content (max 1000 characters)
        - attachment

4. Hashtag
    - The top 5 trending hashtags in the past 24 hours can be fetched


### Out-Scope
1. Authentication and authorization

<br/>

## How To Run
### Requirements
1. Ruby version ^2.7.3
2. MySql Server
3. API Client (Postman, Thunder Client, etc)
4. Ruby Gems
    1. mysql2
    2. sinatra
    3. sinatra-namespace
    4. rspec
    5. simplecov
    6. rack-test

### Steps
1. Make sure all the dependencies are installed. For Ruby gems, install it with `gem install <gem_name>` e.g. `gem install rspec`
2. Clone this repository
```bash
    $ git clone https://github.com/AldiNFitrah/gg-gram
```
3. Create a new database and test database (you can use other names)
```sql
    mysql> CREATE DATABASE gg_gram;
    mysql> CREATE DATABASE gg_gram_test;
```
4. Import the database schema to both databases
```bash
    $ mysql -u 'username' -p gg_gram < db/schema.sql
    $ mysql -u 'username' -p gg_gram_test < db/schema.sql
```
5. Make the `.env` file based on the `.env.example` and fill in the data
6. Run the application
```bash
    $ ruby main.rb
```
7. To Run the Tests
```bash
    $ rspec -f d
```

## Documentation
- POST `/api/users`
    - To create a user
    - Body:
        - username
        - email
        - bio_description (optional)
- POST `/api/users/<user_id>/post`
    - To create a post by a user with id=`<user_id>`
    - Body:
        - content (optional)
        - attachment (file, optional)
- GET `/api/posts`
    - To get posts filtered by a hashtag
    - Query Params:
        - hashtag (must start with `#`)
- POST `/api/posts/<post_id>/comment`
    - To create a comment to a post with id=`<post_id>`
    - Body:
        - user_id
        - content (optional)
        - attachment (file, optional)
- GET `/api/hashtags/trending`
    - To get the top5 trending hashtags in the past 24 hours
- GET `public/<file_name>`
    - To get the file that was attached before in a post or comment

[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/10569299-8f086fd8-76f1-40a8-8103-9d3c3e7ef408?action=collection%2Ffork&collection-url=entityId%3D10569299-8f086fd8-76f1-40a8-8103-9d3c3e7ef408%26entityType%3Dcollection%26workspaceId%3Db8d810f5-65a6-4867-90bb-09c18d4c214a)