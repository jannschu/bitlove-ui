# Bitlove (Web Interface)

The Bitlove web interface is built with Haskell using the Yesod framework. See [Bitlove.org](http://bitlove.org/) for the actual site.

The Yesod project has [a little book](http://www.yesodweb.com/book). For beginners, read [Real World Haskell](http://book.realworldhaskell.org/read/).

## Installation (for the less experienced)

You’ll need Haskell, Cabal, PostgreSQL and a UNIX OS. You might want to try the [Haskell Platform](http://hackage.haskell.org/platform/), available in most package managers.

Some commands need to be adjusted or left off. Start the installation by running the following ones:

    initdb /usr/local/var/postgres -E utf8
    pg_ctl -D /usr/local/var/postgres start
    createdb prittorrent

Next get the database setup sql files in your project folder:

    wget https://raw.github.com/astro/prittorrent/master/pg_install.sql
    wget https://raw.github.com/astro/prittorrent/master/pg_meta.sql
    wget https://raw.github.com/astro/prittorrent/master/pg_var.sql
    wget https://raw.github.com/astro/prittorrent/master/pg_tracker.sql
    wget https://raw.github.com/astro/prittorrent/master/pg_downloads.sql
    wget https://raw.github.com/astro/prittorrent/master/pg_stats.sql

Open a shell with `psql prittorrent` and enter:

    CREATE USER prittorrent WITH SUPERUSER PASSWORD '1234';
    \i pg_install.sql
    -- ignore the tablespace errors
    \i pg_imagecache.sql
    \q
    rm pg_!(imagecache).sql

Compile and run:

    cabal update && cabal install --only-dependencies
    cabal configure && cabal build
    ./dist/build/ui/ui Development

Now point your browser to `http://localhost:8081/`.


## TODO

* Filter for directory
* Search
* Fix pagination
* Per-item pages
* MapFeed content-type
* URL longener?
* Fix empty downloads.type
* filter.js:
  * Fix z-index (Android?)
* New {feeds,downloads}.{lang,summary,type} in:
  * Downloads Feeds
  * HTML
* enforce https for log in
* `<atom:link rel="self">`
* `<atom:link rel="alternate">`
* style:
  * Fonts
  * Flattr donate
* Edit user:
  * About field
* Edit feeds:
  * Add & fetch immediately
* graphs:
  * refactor
* more configurability
* Fetch & display feed summaries
* Feed summaries: X items, Y torrents
* OEmbed
* Installation: automation, sample data, fix database setup
