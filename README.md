# Docker image for Magento 2.3

:heart: Forked from [this image](https://github.com/alexcheng1982/docker-magento2) :heart:

:warning: This image is for experimenting with Magento 2.3. With this image installing the Venia Concept should only take a few commands.

This repo converts the [long installation guide](http://devdocs.magento.com/guides/v1.0/install-gde/bk-install-guide.html) of Magento 2 into simple Docker image to use. It uses the same convention as my [Docker image for Magento 1.x](https://github.com/alexcheng1982/docker-magento).

For documentation, please refer to the Magento 1.x [repo](https://github.com/alexcheng1982/docker-magento). These two Docker images follow the same instructions. 

__Note__ This docker image uses the *Contributing developer* profile to install Magento, so it has limitations. See more details [here](http://devdocs.magento.com/guides/v2.0/install-gde/bk-install-guide.html).

**Please note: this Docker image is for development and testing only, not for production use. Setting up a Magento 2 production server requires more configurations. Please refer to [official documentations](http://devdocs.magento.com/guides/v2.2/config-guide/deployment/).**

## Magento 2 installation types

Magento 2 has three different ways to [install](http://devdocs.magento.com/guides/v2.0/install-gde/bk-install-guide.html), for users, integrators and developers. This Docker image uses **integrator** as the default installation type, so the **Web Setup Wizard** can be used. For each version, both integrator and developer installation types are available. The user installation type is not currently supported.

For example, Magento 2 version `2.2.2` has tag `2.2.2`, `2.2.2-integrator` and `2.2.2-developer`. `2.2.2` is the same as `2.2.2-integrator`.

Below are some basic instructions.

## Quick start

The easiest way to start Magento 2 with MySQL is using [Docker Compose](https://docs.docker.com/compose/). Just clone this repo and run following command in the root directory. The default `docker-compose.yml` uses MySQL and phpMyAdmin.

~~~
$ docker-compose up -d
~~~

For admin username and password, please refer to the file `env`. You can also update the file `env` to update those configurations. Below are the default configurations.

~~~
MYSQL_HOST=db
MYSQL_ROOT_PASSWORD=myrootpassword
MYSQL_USER=magento
MYSQL_PASSWORD=magento
MYSQL_DATABASE=magento

MAGENTO_LANGUAGE=en_GB
MAGENTO_TIMEZONE=Pacific/Auckland
MAGENTO_DEFAULT_CURRENCY=NZD
MAGENTO_URL=http://local.magento
MAGENTO_BACKEND_FRONTNAME=admin
MAGENTO_USE_SECURE=0
MAGENTO_BASE_URL_SECURE=0
MAGENTO_USE_SECURE_ADMIN=0

MAGENTO_ADMIN_FIRSTNAME=Admin
MAGENTO_ADMIN_LASTNAME=MyStore
MAGENTO_ADMIN_EMAIL=amdin@example.com
MAGENTO_ADMIN_USERNAME=admin
MAGENTO_ADMIN_PASSWORD=magentorocks1
~~~

For example, if you want to change the default currency, just update the variable `MAGENTO_DEFAULT_CURRENCY`, e.g. `MAGENTO_DEFAULT_CURRENCY=USD`.

You can find all available options in the official [setup guide](http://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-install.html#instgde-install-cli-magento). If you need more options, fork this repo and add them in `bin\install-magento`.

Please see the following video for a quick demo.

[![Use Magento 2 with Docker](https://img.youtube.com/vi/18tOf_cuQKg/hqdefault.jpg)](https://www.youtube.com/watch?v=18tOf_cuQKg "Use Magento 2 with Docker")

## Installation

After starting the container, you'll see the setup page of Magento 2. You can use the script `install-magento` to quickly install Magento 2. The installation script uses the variables in the `env` file.

### Magento 2

~~~
$ docker exec -it <container_name> install-magento
~~~

### Sample data

~~~
$ docker exec -it <container_name> install-sampledata
~~~

### Database

The default `docker-compose.yml` uses MySQL as the database and starts [phpMyAdmin](https://www.phpmyadmin.net/). The default URL for phpMyAdmin is `http://localhost:8580`. Use MySQL username and password to log in.

## FAQ

### Where is the database?

Magento 2 cannot run with a database. This image is for Magento 2 only. It doesn't contain MySQL server. MySQL server should be started in another container and linked with Magento 2 container. It's recommended to use Docker Compose to start both containers. You can also use [Kubernetes](https://kubernetes.io/) or other tools.

### Why accessing http://local.magento?

For development and testing in the local environment, using `localhost` as Magento 2 URL has some issues. The default `env` file use `http://local.magento` as the value of `MAGENTO_URL`. You need to [edit your `hosts` file](https://support.rackspace.com/how-to/modify-your-hosts-file/) to add the mapping from `local.magento` to `localhost`. You can use any domain names as long as it looks like a real domain, not `localhost`.

If `localhost` doesn't work, try using `127.0.0.1`.

```
127.0.0.1    local.magento
```

### How to update Magento 2 installation configurations?

Depends on how the container is used,

* When using the GUI setup page of Magento 2, update configurations in the UI.
* When using the script, update configurations in the `env` file. 
* When starting Magento 2 as a standalone container, use `-e` to pass environment variables.

### Why getting access denied error after changing the default DB password?

If you change the default DB password in `env` file and get the access denied error when installing Magento 2, see [this issue comment](https://github.com/alexcheng1982/docker-magento2/issues/10#issuecomment-355382150).

## Develop and test using this Docker image

As I mentioned before, this Docker image is primarily used for development and testing. Depends on the tasks you are trying to do, there are different ways to use this Docker image.

### Extensions and themes

You can keep the extensions and themes directories on your local host machine, and use Docker Compose [volumes](https://docs.docker.com/compose/compose-file/#volumes) to install the extensions and themes. For example, if you have a theme in the directory `/dev/mytheme`, you can install it by specifying it in the `docker-composer.yml` file. Then you can see the theme in Magento admin UI.

```yml
version: '3.0'
services:
  web:
    image: alexcheng/magento2
    ports:
      - "80:80"
    links:
      - db
    env_file:
      - env
    volumes:
      - /dev/mytheme:/var/www/html/app/design/frontend/mytheme/default
  db:
    image: mysql:5.6.23
    volumes:
      - db-data:/var/lib/mysql/data
    env_file:
      - env
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    ports:
      - "8580:80"
    links:
      - db
volumes:
  db-data:
```

### Setting up Venia

[Venia](https://github.com/magento-research/pwa-studio/tree/master/packages/venia-concept) is a proof of concept theme using the new PWA tools that magento 2.3 will come with.

1. run `git clone https://github.com/magento-research/pwa-studio.git`
   wherever you wish to keep the PWA code.
2. The version number in Venia is blank, after description add ..."version: "1.0"
3. In the docker-compose.yml file set-up a volume that points to
   `path-to-pwa-studio/packages/venia-concept` and
   `path-to-pwa-studio/packages/pwa-module` (reference the previous section).
   Reference the `link module` and `link theme directory` section of the `setup
   venia guide` [here](https://magento-research.github.io/pwa-studio/venia-pwa-concept/setup/).
   Note: Creating volume mounts satisfies the need to create `sym` links.
   A good way to accomplish this is to use a [docker-compose override](https://docs.docker.com/compose/extends/);
4. Run the `install-venia` script in the docker image. `docker exec -it container_id install-venia`.
5. Follow the rest of the setup guide starting with `Set environement variables`
   [here](https://magento-research.github.io/pwa-studio/venia-pwa-concept/setup/).
   The magento base url will be the url of the Magento2 docker image (should be
   `https://local.magento`) 
6. At this point you should be able to run `npm start` and see the current
   progress on the `venia` concept. If you have a problem, feel free to submit an
   issue!

Note: The `composer.json` file includes the venia concept as a dev requirement. 

### Modify Magento core files

If you want to modify Magento core files, you cannot modify them directly in the container. Those changes will be lost. It's also not recommended to update Magento core files directly, which makes upgrading Magento a painful process. Actually, Docker makes the process much easier if you absolutely need to modify some core files. You can use volumes to overwrite files.

For example, if you want to overwrite the file `app/code/Magento/Catalog/Block/Product/Price.php`, you can copy the content to a new file in your local directory `/dev/mycode/magento_2_2` and make the changes, then use `volumes` to overwrite it.

```yml
volumes:
  - /dev/mycode/magento_2_2/app/code/Magento/Catalog/Block/Product/Price.php:/var/www/html/app/code/Magento/Catalog/Block/Product/Price.php
```

By using Docker, we can make sure that all your changes to Magento core files are kept in one place and tracked in source code repository. These changes are also correctly aligned with different Magento versions.

When deploying those changes to production servers, we can simply copy all files in the `/dev/mycode/magento_2_2` directory to Magento installation directory and overwrite existing files.

### Test Magento compatibilities

This Docker images has different tags for corresponding Magento versions, e.g. `2.2.1`, `2.2.2`. You can switch to different Magento versions very easily when testing extensions and themes.
