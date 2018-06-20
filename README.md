![PHP 7.2.x](https://img.shields.io/badge/PHP-7.2.x-green.svg)
![PHP 7.1.x](https://img.shields.io/badge/PHP-7.1.x-green.svg)
![PHP 7.0.x](https://img.shields.io/badge/PHP-7.0.x-green.svg)
![PHP 5.6.36](https://img.shields.io/badge/PHP-5.6.36-green.svg)
![PHP 5.5.38](https://img.shields.io/badge/PHP-5.5.38-green.svg)
![PHP 5.4.45](https://img.shields.io/badge/PHP-5.4.45-green.svg)
![PHP 5.3.29](https://img.shields.io/badge/PHP-5.3.29-green.svg)
![PHP 5.2.4](https://img.shields.io/badge/PHP-5.2.4-green.svg)


```
 __          _______  _      _ _       ____
 \ \        / /  __ \| |    (_) |     |  _ \
  \ \  /\  / /| |__) | |     _| |__   | |_) | _____  __
   \ \/  \/ / |  ___/| |    | | '_ \  |  _ < / _ \ \/ /
    \  /\  /  | |    | |____| | |_) | | |_) | (_) >  <
     \/  \/   |_|    |______|_|_.__/  |____/ \___/_/\_\
```

![WPLib-Box](https://github.com/wplib/wplib.github.io/raw/master/WPLib-Box-100x.png)


# PHP Docker Container for WPLib Box
This is the repository for the [PHP](https://php.org/) Docker container implemented for [WPLib-Box](https://github.com/wplib/wplib-box).
It currently provides versions 5.2.4 5.3.29 5.4.45 5.5.38 5.6.36 7.0.x 7.1.x 7.2.x


## Supported tags and respective build directories
`7.2.6`, `7.2`, `latest` _([7.2.6/](https://github.com/wplib/php-docker/blob/master/7.2.6/))_

`7.1.18`, `7.1` _([7.1.18/](https://github.com/wplib/php-docker/blob/master/7.1.18/))_

`7.0.30`, `7.0` _([7.0.30/](https://github.com/wplib/php-docker/blob/master/7.0.30/))_

`5.6.36`, `5.6` _([5.6.36/](https://github.com/wplib/php-docker/blob/master/5.6.36/))_

`5.5.38`, `5.5` _([5.5.38/](https://github.com/wplib/php-docker/blob/master/5.5.38/))_

`5.4.45`, `5.4` _([5.4.45/](https://github.com/wplib/php-docker/blob/master/5.4.45/))_

`5.3.29`, `5.3` _([5.3.29/](https://github.com/wplib/php-docker/blob/master/5.3.29/))_

`5.2.4`, `5.2` _([5.2.4/](https://github.com/wplib/php-docker/blob/master/5.2.4/))_


## Using this container.
If you want to use this container as part of WPLib, then use the Docker Hub method.
Or you can use the GitHub method to build and run the container.


## Using it from Docker Hub

### Links
(Docker Hub repo)[https://hub.docker.com/r/wplib/php/]

(Docker Cloud repo)[https://cloud.docker.com/swarm/wplib/repository/docker/wplib/php/]


### Setup from Docker Hub
A simple `docker pull wplib/php` will pull down the latest version.


### Runtime from Docker Hub
start - Spin up a Docker container with the correct runtime configs.

`docker run -d --name wplib_php_7.1 --restart unless-stopped --network wplibbox -p 9000:9000 --mount type=bind,source=/var/www,target=/var/www --mount type=bind,source=/srv/sites,target=/srv/sites wplib/php:7.1`

stop - Stop a Docker container.

`docker stop wplib_php_7.1`

run - Run a Docker container in the foreground, (all STDOUT and STDERR will go to console). The Container be removed on termination.

`docker run --rm --name wplib_php_7.1 --network wplibbox -p 9000:9000 --mount type=bind,source=/var/www,target=/var/www --mount type=bind,source=/srv/sites,target=/srv/sites wplib/php:7.1`

shell - Run a shell, (/bin/bash), within a Docker container.

`docker run --rm --name wplib_php_7.1 -i -t --network wplibbox -p 9000:9000 --mount type=bind,source=/var/www,target=/var/www --mount type=bind,source=/srv/sites,target=/srv/sites wplib/php:7.1 /bin/bash`

rm - Remove the Docker container.

`docker container rm wplib_php_7.1`


## Using it from GitHub repo

### Setup from GitHub repo
Simply clone this repository to your local machine

`git clone https://github.com/wplib/php-docker.git`


### Building from GitHub repo
`make build` - Build Docker images. Build all versions from the base directory or specific versions from each directory.


`make list` - List already built Docker images. List all versions from the base directory or specific versions from each directory.


`make clean` - Remove already built Docker images. Remove all versions from the base directory or specific versions from each directory.


`make push` - Push already built Docker images to Docker Hub, (only for WPLib admins). Push all versions from the base directory or specific versions from each directory.


### Runtime from GitHub repo
When you `cd` into a version directory you can also perform a few more actions.

`make start` - Spin up a Docker container with the correct runtime configs.


`make stop` - Stop a Docker container.


`make run` - Run a Docker container in the foreground, (all STDOUT and STDERR will go to console). The Container be removed on termination.


`make shell` - Run a shell, (/bin/bash), within a Docker container.


`make rm` - Remove the Docker container.


`make test` - Will issue a `stop`, `rm`, `clean`, `build`, `create` and `start` on a Docker container.


