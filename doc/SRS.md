# Project Omnildap Software Requirement Specification
### 1 Global 
 ?

###  2 Basic setup
 - 2.1 Code repository shall be at https://code.sonymobile.net
 - 2.2 Omnildap shall contain a web server application
 - 2.3 Omnildap shall answer ldap requests
 - 2.4 It shall be possible to run Omnildap temporarily without backend access

### 3 User
 - 3.1 A user must belong to at least one backend

### 4 Proxy/Backend
 - 4.1 CRUD backend
 - 4.2 It shall be possible to use local persistence as backend (i.e. Omnildap serving as its own backend)
 - 4.3 It shall be possible to use LDAP server as backend
 - 4.4 It shall be possible to use non-LDAP server as backend
 - 4.5 User CRUD shall reflect users as CRUD:ed on backends
 - 4.6 It shall be possible to block a user
 - ~~4.7 It shall be possible to allow user deletion on backend be reflected as either delete or blocking of that user~~
 - 4.8 A user shall exist as long as it exists with any existing backend
 - 4.9 It shall be possible to block a backend
 - 4.10 Deleting a backend shall delete all users only existing on that backend
 - 4.11 Blocking a backend shall block all users only existing on that backend
 - 4.12 It shall be possible to block user access to backend based on email

### 5 Group
 - 5.1 It shall be possible for groups to contain any number of users
 - ~~5.2 A group must belong to at least one backend~~
 - ~~5.3 Group CRUD shall reflect groups as CRUD:ed on backends~~

### 6 LDAP
 - 6.1 It shall be possible to do a top-level/admin bind request
 - 6.2 It shall be possible to retrieve a user entry by cn
 - 6.3 It shall be possible to retrieve a user entry by mail
 - 6.4 It shall be possible to retrieve a user entry by samaccountname
 - 6.5 A user shall be able to authenticate
 - 6.6 It shall be possible to retrieve a group by cn
 - 6.7 It shall be possible to retrieve a list of members in a group
 - 6.8 It shall be possible to retrieve a list of groups a user is member of
