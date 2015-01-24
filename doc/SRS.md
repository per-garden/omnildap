# Project Omnildap Software Requirement Specification
### 1 Global 
 ?

###  2 Basic setup
 - 2.1 Code repository shall be at https://code.sonymobile.net
 - 2.2 Omnildap shall contain a web server application
 - 2.2 Omnildap shall answer ldap requests
 - 2.3 It shall be possible to run Omnildap temporarily without backend access

### 3 User
 - 3.2 User shall be able to acquire LDAP authentication
 - 3.3 A user must belong to at least one backend

### 4 Proxy/Backend
 - 4.1 CRUD backend
 - 4.2 It shall be possible to use local persistence as backend (i.e. Omnildap serving as its own backend)
 - 4.3 It shall be possible to use other LDAP server as backend
 - 4.4 It shall be possible to use other non-LDAP server as backend
 - 4.5 It shall be possible to retrieve user CRUD information from backends
 - 4.6 User CRUD shall reflect users as CRUD:ed on backends
 - 4.7 It shall be possible to block a user
 - 4.8 It shall be possible to allow user deletion on backend be reflected as either delete or blocking of that user
 - 4.9 A user shall exist as long as it exists with any existing backend
 - 4.10 It shall be possible to block a backend
 - 4.11 Deleting a backend shall delete all users only existing on that backend
 - 4.12 Blocking a backend shall block all users only existing on that backend
