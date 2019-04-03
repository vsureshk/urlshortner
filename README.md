# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* Please find details of system:

- Ruby - 2.5.1, Rails - 5.2.3, Database - sqlite
- Used git
- After cloning the app, follow below steps to run application

   1.$bundle install
   2.$rails db:create
   3.$rails db:migrate
   4.$rails server

   **Access http://localhost:3000(If running application in local)**

   -Enter original URL and click submit
   -short url is generated
   -Access the short url Ex: http://localhost:3000/sdhrg
   -Access http://localhost:3000/stats for analytics details

 - For running test cases
$rails db:migrate RAILS_ENV=test
$rspec spec

-you can find test coverage in coverage/index.html

**scalability issues:**

**1.Capacity estimation and constraints**

There will be lots of redirection requests compared to new URL shortenings.Our system will be ready-heavy.Let’s assume 100:1 ratio between read and write

**Traffic estimates:**
  Assuming, we will have 500M new URL shortenings per month, with 100:1 read/write ratio, we can expect 50B redirections during the same period.

**Storage estimates:**
  Let’s assume we store every URL shortening request (and associated shortened link) for 5 years. Since we expect to have 500M new URLs every month, the total number of objects we expect to store will be 30 billion.

**Bandwidth estimates:**
  For write requests, since we expect 200 new URLs every second, total incoming data for our service will be 100KB per second.

**Memory estimates:**
  If we want to cache some of the hot URLs that are frequently accessed, how much memory will we need to store them? If we follow the 80-20 rule, meaning 20% of URLs generate 80% of traffic, we would like to cache these 20% hot URLs.

To cache 20% of these requests, we will need 170GB of memory.

One thing to note here is that since there will be a lot of duplicate requests (of the same URL), therefore, our actual memory usage will be less than 170GB.

High level estimates: Assuming 500 million new URLs per month and 100:1 read:write ratio, following is the summary of the high level estimates for our service:

New URLs	200/s
URL redirections	19K/s
Incoming data	100KB/s
Outgoing data	9MB/s
Storage for 5 years	15TB
Memory for cache	170GB


**2.System APIs**

  Its a good idea to define the system APIs.we can use SOAP to expose functionality of our service.

  How do we detect and prevent abuse? A malicious user can put us out of business by consuming all URL keys in the current design. To prevent abuse, we can limit users via their api_dev_key. Each api_dev_key can be limited to a certain number of URL creations and redirections per some time period (which may be set to a different duration per developer key).

**3.Database design**

  A few observations about the nature of the data we will store:
  - We need to store billions of records.
  - Each object we store is small (less than 1K).
  - There are no relationships between records—other than storing which user created a URL.
  - Our service is read-heavy.

  Database schema:
    We would need two tables: one for storing information about the URL mappings, and one for the user’s data who created the short link.

  What kind of database should we use? Since we anticipate storing billions of rows, and we don’t need to use relationships between objects – a NoSQL key-value store like DynamoDB, Cassandra or Riak is a better choice. A NoSQL choice would also be easier to scale. Please see SQL vs NoSQL for more details.

**4.Basic System Design and Algorithm**

  The problem we are solving here is, how to generate a short and unique key for a given URL.

  We’ll explore two solutions here:

  **a. Encoding actual URL**

  We can compute a unique hash (e.g., MD5 or SHA256, etc.) of the given URL. The hash can then be encoded for displaying. This encoding could be base36 ([a-z ,0-9]) or base62 ([A-Z, a-z, 0-9]) and if we add ‘-’ and ‘.’ we can use base64 encoding. A reasonable question would be, what should be the length of the short key? 6, 8 or 10 characters.

  What are different issues with our solution? We have the following couple of problems with our encoding scheme:

  - If multiple users enter the same URL, they can get the same shortened URL, which is not acceptable.
  - What if parts of the URL are URL-encoded?

  Workaround for the issues: We can append an increasing sequence number to each input URL to make it unique, and then generate a hash of it. We don’t need to store this sequence number in the databases, though. Possible problems with this approach could be an ever-increasing sequence number. Can it overflow? Appending an increasing sequence number will also impact the performance of the service.

  Another solution could be to append user id (which should be unique) to the input URL. However, if the user has not signed in, we would have to ask the user to choose a uniqueness key. Even after this, if we have a conflict, we have to keep generating a key until we get a unique one.

  **b. Generating keys offline**

  We can have a standalone Key Generation Service (KGS) that generates random six letter strings beforehand and stores them in a database (let’s call it key-DB). Whenever we want to shorten a URL, we will just take one of the already-generated keys and use it. This approach will make things quite simple and fast. Not only are we not encoding the URL, but we won’t have to worry about duplications or collisions. KGS will make sure all the keys inserted into key-DB are unique

  Can concurrency cause problems? As soon as a key is used, it should be marked in the database to ensure it doesn’t get used again. If there are multiple servers reading keys concurrently, we might get a scenario where two or more servers try to read the same key from the database.

  Servers can use KGS to read/mark keys in the database. KGS can use two tables to store keys: one for keys that are not used yet, and one for all the used keys.

**5.Data Partitioning and Replication**

To scale out our DB, we need to partition it so that it can store information about billions of URLs. We need to come up with a partitioning scheme that would divide and store our data to different DB servers.

a. Range Based Partitioning: We can store URLs in separate partitions based on the first letter of the URL or the hash key. Hence we save all the URLs starting with letter ‘A’ in one partition, save those that start with letter ‘B’ in another partition and so on. This approach is called range-based partitioning.

The main problem with this approach is that it can lead to unbalanced servers. For example: we decide to put all URLs starting with letter ‘E’ into a DB partition, but later we realize that we have too many URLs that start with letter ‘E’.

b. Hash-Based Partitioning: In this scheme, we take a hash of the object we are storing. We then calculate which partition to use based upon the hash. In our case, we can take the hash of the ‘key’ or the actual URL to determine the partition in which we store the data object.

This approach can still lead to overloaded partitions, which can be solved by using Consistent Hashing.

**6.cache**

We can cache URLs that are frequently accessed. We can use some off-the-shelf solution like Memcache, which can store full URLs with their respective hashes. The application servers, before hitting backend storage, can quickly check if the cache has the desired URL.

**7.Load Balancer**

We can add a Load balancing layer at three places in our system:

Between Clients and Application servers
Between Application Servers and database servers
Between Application Servers and Cache servers

**8.Purging or DB cleanup**

Should entries stick around forever or should they be purged? If a user-specified expiration time is reached, what should happen to the link?

If we chose to actively search for expired links to remove them, it would put a lot of pressure on our database. Instead, we can slowly remove expired links and do a lazy cleanup. Our service will make sure that only expired links will be deleted, although some expired links can live longer but will never be returned to users.

**9.Telemetry**

How many times a short URL has been used, what were user locations, etc.? How would we store these statistics? If it is part of a DB row that gets updated on each view, what will happen when a popular URL is slammed with a large number of concurrent requests?

Some statistics worth tracking: country of the visitor, date and time of access, web page that refers the click, browser, or platform from where the page was accessed.

**10.Security and Permissions**

Can users create private URLs or allow a particular set of users to access a URL?

We can store permission level (public/private) with each URL in the database. We can also create a separate table to store UserIDs that have permission to see a specific URL. If a user does not have permission and tries to access a URL, we can send an error (HTTP 401) back.
