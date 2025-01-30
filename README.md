sql2dia
=======

This software allows you to quickly generate a Dia diagram straight from the database.

For now it only generates a "class" diagram with one class for each table in the database, and all columns as "class attributes".

Installation
------------

The application uses basic Perl modules to do it's thing.

You should be able to use any Perl 5 that works for you. The app was last tested on [Strawberry Perl 5.30](http://strawberryperl.com/) on Windows, but should work for other editions and systems.

Steps:
1. Install Perl (again Strawberry should work fine).
2. `cpanm DBD::Pg`(*). (or if tests fail run: `cpanm --force DBD::Pg`)
3. `cpanm Getopt::Mixed`.

(*) Until PG10 this script used `DBD::PgPP`. It doesn't seem to be developed anymore and `DBD::Pg` seems like a good replacement.

Note if your are using `ppm` for installing modules then the module names are slightly different. For example for PgPP this worked for me in old Perl installation (perl-camelpack-5.8.7):
```
ppm install DBD-pgPP
```

To open the diagram use [Dia the UML diagram editor](https://wiki.gnome.org/Apps/Dia).


Basic usage
-----------

On Linux:
```
pgsql2dia -d database_name -u user -p password
```

On Windows:
```
perl pgsql2dia -d database_name -u user -p password
```

Note that `pgsql2dia` and `mysql2dia` share the same basic syntax for parameters.

Run without parameters to see more usage options:
```
perl pgsql2dia
```

Authors
-------

* Itamar Almeida de Carvalho -- original author.
* Maciej Nux Jaros -- PostgreSQL support.
* Ken Gilmer -- special thanks for his patch to support database authentication.

License and original notes
--------------------------

For more information about the GPL, see the `COPYING` file.

Orignal notes in: `README`.