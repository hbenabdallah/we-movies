**We-movies Symfony-Stack** is a **Symfony** stack for web applications and a set of reusable
**PHP components**.
This stack is dockerized and compatible with **linux** distribution.

Installation
------------

To install this Symfony stack, run:
```shell script
  make install
  make databse-migrate
  make load-fixtures
  ```

Then, to run the application:
```shell script
  make start
  ```

Help
----

To find all available commands, run:
```shell script
  make help
  ```

Instructions
------------

We have prepared for you several files under the "bin" folder to execute any command directly under docker.

For example, to execute "bin/console cache:clear" command run:

```shell script
bin/php bin/console cache:clear
```


To use Webpack, you must:

Enter the cotntainer:
```shell script
make docker-main
```
and run
```shell script
npm run dev
```
