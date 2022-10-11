<p align="center"><img src="./logo.png"></p>

# Local Lens Custom Wordpress Theme Development Server
Local Lens connects customers with professional photographers for vacation photoshoots and other special events (such as marriage proposals). The site allows customers to research and select destinations and hire photographers for those events. 

## DNS Preparation

### Overview
The Local Lens site is a standard single-site WordPress installation running a custom WordPress theme and plugin for integration with a custom photographer API (also developed and maintained by Curious Minds Media). For development purposes, the Docker containers in this repo are set up to use SSL (via a self-signed certificate) and are also set up for optional debugging and code profiling using XDebug. In order to develop under this setup, you will need to create a DNS configuration on your local machine that routes all requests from a `*.local` top-level domain to your Docker development server. This readme also contains instructions for setting up DNSmasq on your machine, which is essential.

### Steps
1. Download and install [Docker](https://docker.com) for your machine. Follow the directions and install it.
2. Download and install [Homebrew](https://brew.sh/), or update it if you already have it.
3. Install DNSMasq via Homebrew: `brew install dnsmasq`.
4. Follow [these instructions](https://passingcuriosity.com/2013/dnsmasq-dev-osx/) to forward `*.local` domains to `localhost`. (Select option #2 under the 'Configuring OS X' Section). Note that if you run into any difficulties, you can also try [these instructions](https://www.larry.dev/no-more-etc-hosts-on-mac-with-dnsmasq/).

> Note: If you already have the project set up, you can skip the Project Installation step and simply stop and restart you Docker instance after pulling from GitHub to enable the reverse proxy. All other steps are the same.

## Project Installation
1. Make sure your Docker installation is running.
2. Pull this repository down to your computer, wherever you would like it located.
3. In Terminal, navigate to the root of your project folder (the same folder that contains this README file).
4. Create a folder called `certs`:
```
mkdir certs
```
5. Run the following command to create and install a self-signed SSL certificate:
```
openssl req -x509 -out certs/locallens.local.crt -keyout certs/locallens.local.key -newkey rsa:2048 -nodes -sha256 -subj '/CN=locallens.local' -extensions EXT -config <( printf "[dn]\nCN=locallens.local\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:locallens.local\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```
6. From the project root folder in Terminal, run `docker build -t wordpress_xdebug . && docker-compose up`; this will pull down the Docker boxes, create a custom image for WordPress with XDebug, and create the usual WordPress files and folders, as well as a folder called `db_data`.
7. Open the site (https://locallens.local) in your browser and run through the initial WordPress installation procedure; it doesn't matter what you put here, just remember the username/password and then log in afterward. (Note that the first time to you try to open the local URL, you will get a security warning that your certificate is invalid. Technically it is, because it's self-signed and not from a valid certificate authority. Ingore this warning and proceed to the site. SSL will function correctly, though it will continue to be crossed out in red in the address bar.) If your certificate expires (which it normally does after 90 days), just run the above command again to generate a new one.
8. Download the latest site backup from WP Engine. 
9. Copy your downloaded `wp-content` folder to the `wp-content` folder of your new local WordPress install. (Also see Gotchas below for an important note on images.)
10. Connect to the local Docker MySQL instance from your SQL editor of choice. (Check the `docker-compose.yml` file for the credentials. The connection port is `33060`.) Alternatively, you can access phpMyAdmin at http://localhost:8080.
11. In the `wp-content` folder that you downloaded, you will find a `mysql.sql` file. Execute this against the local SQL database. (See Gotchas below if you experience errors.)
12. Edit the values `siteurl` and `home` in the  `wp_options` table to `https://locallens.local`.
13. At this point, you will notice that you are kicked out of the WordPress Admin. Login again, this time using the Local Lens site credentials from Teams ID.
14. If you get an error stating too many redirects, you will also need to edit the URLs in the `wp_blogs` and `wp_site` tables.
15. Use the [Better Search Replace plugin](https://wordpress.org/plugins/better-search-replace/) to change all URLs in the database to match your local development URL.

> Note: All logic and views should be created in the custom WordPress theme. Do not alter the core WordPress folders.

## Preparing XDebug for PHP Step Debugging and Profiling
1. Run the following Terminal command from your project root folder to be able to access XDebug output (error log and profiler data):
```
mkdir xdebug && touch xdebug/error.log
```
2. Install the [Xdebug helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc?hl=en) extension for Chrome with the following settings in order to perform either step debugging or code profiling:
* IDE key: `Other` `XDEBUG_DOCKER`
* Trace Trigger Value: `XDEBUG_TRACE`
* Profile Trigger Value: `XDEBUG_PROFILE`

See [this page](https://langui.sh/2011/06/16/how-to-install-qcachegrind-kcachegrind-on-mac-osx-snow-leopard/) for details on installing `qcachegrind` to analyze the profiler output. (Note that you will have to use `qmake -spec macx-clang` in place of the `qmake -spec 'macx-g++'` command on that page, and you can use `git clone https://github.com/KDE/kcachegrind` if you don't have SVN available.)

## Working on the Custom Theme
1. Make sure you are using PHP 7.4 (`php -v` to confirm).
2. Make sure you are using Node 12 (`node -v` to confirm, `nvm use 12` to change).
3. Make sure you have the latest version of Yarn installed.
4. You should not *ever* need to run `composer install` or `composer update`!
5. The first time after cloning the project, navigate to the theme folder (`wp-content/themes/locallens-wp-admin`) in Terminal and run `yarn`. This will create the `node_modules` folder needed for theme development. (Note that this folder should *never* be uploaded to the live site or committed to the repo.)

* To build the theme for local testing: `yarn build`
* To begin Browsersync for live development: `yarn start`
* To run the script linter: `yarn run lint:scripts`
* To run the style linter: `yarn run lint:styles`
* To build for production: `yarn build:production`

### Technology Stack
* [Roots/Sage v9](https://docs.roots.io/sage/9.x/installation)
* [Tailwind CSS v3](https://tailwindcss.com/docs/installation)
* [AlpineJS v3](https://alpinejs.dev/start-here)
* [Controller](https://github.com/soberwp/controller)
* [Models](https://github.com/soberwp/models)
* [Extended CPTs](https://github.com/johnbillion/extended-cpts)
* [jQuery](https://api.jquery.com/)
* [SASS](https://sass-lang.com/documentation/)
* [Advanced Custom Fields](https://www.advancedcustomfields.com/resources/)

For details on getting started and working with Sage Roots v9, see [this series](https://www.freshconsulting.com/insights/blog/modernizing-wordpress-development-sage-9-part-1/).

## Gotchas and Other Notes
* If you get an error when importing the MySQL database that says "#1118 - Row size too large (> 8126) ...", open the `mysql.sql` file, find the ``CREATE TABLE `wp_bwg_theme` (...`` command, and at the very end (i.e., after all the column definitions), change the engine from InnoDB to MyISAM (i.e., `ENGINE=MyISAM`) and try the import again.
* If Yarn is giving you any issues, make sure you are using the correct PHP and Node versions. If necessary, you can delete the `node_modules` folder and re-run `yarn`.
* Images on the production site are stored in S3, not in the server filesystem, so when setting up your local dev environment, you will need to download and merge the `wp-content` folders from the AWS buckets into your local `wp-content` folder. Follow [this guide](https://wpengine.com/support/copying-files-s3-buckets-large-fs/) to download the files. You will need to get the access ID and secret key stored in the `aws_settings` key of the `wp_options` table in the database. The bucket names are `locallens-photography` and `locallens-photography-2018`, and the location is `us-east-2`. Be aware that the total download size is approximately 26GB.
* If you get PHP errors stating that there are undefined constants, you will need to copy and paste the following `define`d constants from the dev site's `wp-config.php` file (access via SFTP): `WPE_APIKEY`, `PWP_NAME`, `WPE_CLUSTER_ID`, `WPE_LBMASTER_IP`.
* If you receive any errors involving the REST API, try resetting your permalinks twice (Settings > Permalinks > Save Changes).
