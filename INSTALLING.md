# Requirements
To run Aardbei, you will need a UNIX operating system, which basically means
that you need to be running either macos or some flavour of Linux.
Running on Windows might very well be possible, but I haven't tried it.

The Ruby-version Aardbei uses is currently 2.5.3, and to ensure that the version
is always available, and does not conflict with any system installation of some
other Ruby version, the supported way to install it is by compiling from source
using the platform-independent tool [rbenv], with two helper tools called
[ruby-build] and [rbenv-vars].

You will need the following tools installed in whatever way you like:
- [Git]
- Your distro's equivalent of `build-essential` (`make`, `gcc`, probably other
	tools)
- Development headers for `openssl`, `zlib` and `readline` (Ubuntu: `sudo apt
	install libssl-dev zlib1g-dev libreadline-dev`)
- Nodejs (`apt install nodejs`) for Javascript minifying.
- In production: a working `postgresql` installation, with the development
	headers for libpq (`apt install libpq-dev`). Other databases will probably
	work because ActiveRecord should support it, but I'm using Postgres on my
	own server, and haven't tested anything besides sqlite yet.
	
	If you're using MariaDB / MySQL, you'll need the development headers for `libmysql-client` / `libmariadb-client`.
	On Ubuntu: `apt install libmariadb-client-lgpl-dev-compat`.
- In development: libsqlite3 with development headers (`apt install
	libsqlite3-dev`)

# Installing rbenv, ruby-build, and rbenv-vars, and adding it to your shell

## Installing rbenv
To not depend on your distro's version of `rbenv` (if any), we install from
rbenv's repository.

Clone the rbenv repository to your home directory:

```console
$ git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```

Try to compile the bash extension (this makes some things faster, but it doesn't matter if this fails):

```console
$ cd ~/.rbenv; src/configure; make -C src; cd -
```

Add `rbenv` to your `$PATH` (note the double `>>`, a single `>` will trash your
`.bashrc`!):

```console
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc
$ source ~/.bashrc
```

## Installing ruby-build, compiling ruby
`ruby-build` is a plugin for `rbenv` that provides automated compilation and
installation of Ruby.

Create the plugin-directory, and clone the repository to it:

```console
$ mkdir -p ~/.rbenv/plugins
$ git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

Ensure you have the dependencies listed above installed (`build-essential` and
the development headers for `openssl`, `libreadline` and `zlib`). Now start the
compilation of Ruby (this will take a while and will not show a progress bar):

```console
$ rbenv install
```

If all is well, you will get some success message, if you have an error the
script usually tells you what went wrong.

## Installing rbenv-vars
`rbenv-vars` is another plugin for `rbenv` that allows us to easily set
environment variables by listing them in the file `.rbenv-vars`.

Install it by cloning the repository:

```console
$ git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars
```

Copy the template `.rbenv-vars-sample` to `.rbenv-vars`, and set the
environment to `production` or `development`, and the locale to `en` or `nl`,
without quotes.

```
RAILS_ENV=development
# ...
AARDBEI_LOCALE=en
```

Set `AARDBEI_HOSTNAME` to the hostname (no `https://`) your copy is going to run under
(in development it's going to be `localhost:3000`):

```
AARDBEI_HOSTNAME=aardbei.maartenberg.nl
```

If you're planning to run in the production environment, but without a real webserver to serve your assets,
set `RAILS_SERVE_STATIC_FILES=1`. This is not recommended by the Rails team.

Set `AARDBEI_PATH` to the full path of the cloned repository, like `AARDBEI_PATH=/home/aardbei/aardbei`.

# Installing dependencies
Aardbei's dependencies in Ruby are managed using Bundler. To install it, rbenv
needs to know which version of Ruby we're using. This is stored in the file
`.ruby-version`.

Install bundler by moving to your cloned copy of Aardbei, and running:

```console
$ gem install bundler
```

Depending on your environment, run either:

```console
$ bundle install --without=production # in development
$ bundle install --without='development test' # in production
``` 

If all went well, run `rbenv rehash` to add the new executables to your shell,
and test that the installation worked by running `rails`. You should see some
output listing the available subcommands.

Open up your `.rbenv-vars` again, run the command `rails secret`, and set the output as your `SECRET_KEY_BASE`:

```console
SECRET_KEY_BASE=a3a43b...
```

# Setting up the database

## In development: SQLite
When running in the development environment, the database is saved as a file in
the `db` folder. To create it, and pre-fill some test data, run this command:

```console
$ RAILS_ENV=development rails db:setup
```

Note: __The test data currently includes a hardcoded admin user, change this if
needed!__

## In production: Postgresql
Note: these instructions assume you're running Postgres, which is (in my personal experience) more pleasant to manage.
If you want to use a different database, you can do so by defining the `DATABASE_URL` environment variable.

See [this link](https://guides.rubyonrails.org/configuring.html#configuring-a-database) for more information about what
to put in `DATABASE_URL`. If you do this, skip the rest of this section.

If you're not already running Postgresql, install it using `sudo apt install
postgresql-9.5`.

Create a database and user with the following commands:

```console
$ sudo -u postgres psql
postgres=# CREATE ROLE aardbei WITH LOGIN PASSWORD 'aardbei123';
CREATE ROLE
postgres=# CREATE DATABASE aardbei WITH OWNER = aardbei;
CREATE DATABASE
postgres=# GRANT ALL PRIVILEGES ON DATABASE aardbei TO aardbei;
GRANT
postgres=# \q
```

You will probably want to generate a real password for the database instead of
`'aardbei123'`, this can be done by running `rails secret`.

Fill in your database details in `.rbenv-vars`:

```
DB_NAME=aardbei
DB_USER=aardbei
DB_PASS=aardbei123
```

Now set up the database:

```console
$ rails db:setup
```

# Setting up email
Aardbei needs to be able to email in order to send password reset links and
reminders. Set the address for the `From:` field by setting:

```
MAIL_FROM_ADDRESS=aardbei@maartenberg.nl
```

Choose one of the below methods to deliver your mails:

## Using Sendmail
If your system already has working `sendmail`, set `MAIL_METHOD` to `sendmail`.

```
MAIL_METHOD=sendmail
```

## Using Mailgun
If you have your own domain, you can use the free [Mailgun] tier to deliver your emails. In `.rbenv-vars`, set:

```
MAIL_METHOD=mailgun

# ...

MAILGUN_DOMAIN=your.domain.mg
MAILGUN_API_KEY=key-abcdefpdftexexezip
```

## Using SMTP
You can use a SMTP server. Set:

```
MAIL_METHOD=smtp

SMTP_SERVER=email.example.com
SMTP_USER=coolskeleton95
SMTP_PASS=aardbei123
```

# Create an Admin person
If you're not me, you'll want to create your own user. Run:

```console
$ rails console
> p = Person.new
> p.first_name = 'Maarten'
> p.infix = 'van den'
> p.last_name = 'Berg'
> p.email = 'youremail@example.com'
> p.is_admin = 1
> p.save
> exit
```

Note that this has not yet set a password for you: to do that, we need to run a server.

# Running the server directly / in development mode
To start the server, run the command `rails server`. Your terminal will block
until you press Control-C. In addition to this, you will need to be running the
jobs worker to be able to send emails. To start it, run (in another terminal or
before starting the server) `bin/delayed_job start` (or run in the foreground
with `bin/delayed_job run`).

# Running in production
1. Install the Nginx config file in `/etc/nginx/sites-available/aardbei.conf`:

    ```
    upstream aardbeiapp {
        # Replace '/home/aardbei/aardbei' with the path to where you cloned the repository.   
        server unix:/home/aardbei/aardbei/tmp/sockets/puma.sock fail_timeout=0;
    }

    # This server block redirects all non-secure HTTP requests to https://. Remove if unwanted.
    server {
        listen 80;
        listen [::]:80 ipv6only=on;

        server_name aardbei.maartenberg.nl;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        
        # Include your SSL config here!
        include /etc/nginx/ssl_configs.include;

        root /home/aardbei/aardbei/public;
        # Fill in the path to the repository here, and append '/public'.

        server_name aardbei.maartenberg.nl;
        # Fill in your hostname here. Must match the value set in .rbenv-vars.

        location @aardbeiapp {
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_set_header X-Forwarded-Proto https;
            proxy_redirect off;
            proxy_pass http://aardbeiapp;
        }

        error_page 500 502 503 504 /500.html;
        client_max_body_size 4G;
        keepalive_timeout 10;
        try_files $uri @aardbeiapp;
    }
    ```

2. Create a systemd service file to automatically start Aardbei:

    In `/etc/systemd/system/aardbei.service`:
    
    ```systemd
    [Unit]
    Description=Aardbei-server
    After=network.target
    
    [Service]
    User=aardbei
    Group=aardbei
    WorkingDirectory=/home/aardbei/aardbei
    ; Change this to the repository path
    ExecStart=/home/aardbei/.rbenv/shims/puma
    
    [Install]
    WantedBy=multi-user.target
    ```
    
3. Create a systemd service to run jobs (necessary for sending emails):

    In `/etc/systemd/system/aardbei-jobs.service`:
    
    ```systemd
    [Unit]
    Description=Job queue for Aardbei
    After=network.target
    
    [Service]
    User=aardbei
    Group=aardbei
    WorkingDirectory=/home/aardbei/aardbei
    ExecStart=/home/aardbei/.rbenv/shims/bundle exec /home/aardbei/aardbei/bin/delayed_job start
    Type=forking
    PIDFile=/home/aardbei/aardbei/tmp/pids/delayed_jobs.pid
    
    [Install]
    WantedBy=multi-user.target
    ```
    
4. Create a systemd timer and service to clean expired sessions from your database:

    In `/etc/systemd/system/aardbei-clear-sessions.service`:
    
    ```systemd
    [Unit]
    Description=Clear expired Aardbei-sessions
    After=network.target

    [Service]
    User=aardbei
    Group=aardbei
    Type=oneshot
    WorkingDirectory=/home/aardbei/aardbei
    ExecStart=/home/aardbei/.rbenv/shims/rails sessions:clean

    [Install]
    WantedBy=multi-user.target
    ```
    
    In `/etc/systemd/system/aardbei-clear-sessions.timer`:
    
    ```systemd
    [Unit]
    Description=Clear expired Aardbei Sessions weekly
    After=network.target

    [Timer]
    Unit=aardbei-clear-sessions.service
    OnCalendar=weekly

    [Install]
    WantedBy=multi-user.target
    ```
    
5. Run:

    ```console
    $ sudo systemctl daemon-reload
    $ sudo systemctl enable --now aardbei-jobs.service aardbei.service aardbei-sessions.timer
    ```
    
Aardbei will now be running, and will (re)start automatically when your server has rebooted.

# Activating your admin user
To activate your admin user, have your server running and go to
`http://your-server-path/register`. Enter the email address you entered when you
created your Person, and follow the instructions.

<!--* Deployment instructions-->

[rbenv]: https://github.com/rbenv/rbenv
[ruby-build]: https://github.com/rbenv/ruby-build
[rbenv-vars]: https://github.com/rbenv/rbenv-vars
[Git]: https://git-scm.com
[Mailgun]: https://mailgun.com
