# DAViCal Docker container with improved configuration

Docker image for a complete [DAViCal](https://www.davical.org/) server
(DAViCal + Apache2 + PostgreSQL) on Alpine Linux, based on original work
by [Elrondo46](https://github.com/Elrondo46/davical/) and
[datze](https://github.com/datze/davical/).

### Settings added vs original versions

- Only HTTPS on port 443.
- Tidied up volume exposure a little, including /var/log/messages too:
  configuration, data and logs are all persisted and exposed on the
  containing host.
- More explicit certificate configuration.
- Increased CPU timeout to allow for import of large (thousands of
  entries) calendars.
- Formalised configuration somewhat and added a Makefile for
  convenience.  Start by creating your own version of `config.mkf` based
  off this one:

        # Externally visible directory that will contain config/ (for config &
        # certs), data/ (for DB) and log/ (reflecting /var/log).
        local_root:=/somewhere/to/keep/these/important/files

        # My account on Docker
        d_username:=DockerUsername

        # Image name on Docker and locally.
        d_imagename:=davical
        l_imagename:=$(d_imagename)

        # For web server & DAViCal.
        hostname:=davical.example
        timezone:=Europe/London

        # Web server certificates.  Here they're copied into the certs/
        # subdirectory.
        certs:=certs
        pubcert:=$(certs)/cert.pem
        privkey:=$(certs)/privkey.pem

    .. then run `make build`, `make run`, etc.

For further details see [Elrondo46's
README](https://github.com/Elrondo46/davical/) and [datze's
README](https://github.com/datze/davical/).
