# DAViCal Docker Container forked by Elrondo46
Original Project: https://github.com/datze/davical
Docker image for a complete [DAViCal](https://www.davical.org/) server (DAViCal + Apache2 + PostgreSQL) on Alpine Linux.
The repository on github.org contains example configuration files for DAViCal (as well as the Dockerfile to create the Docker image).

### About DAViCal
[DAViCal](https://www.davical.org/) is a server for shared calendars. It implements the [CalDAV protocol](https://wikipedia.org/wiki/CalDAV) and stores calendars in the [iCalendar format](https://wikipedia.org/wiki/ICalendar).

List of supported clients: Mozilla Thunderbird/Lightning, Evolution, Mulberry, Chandler, iCal, ...

**Features**
>    - DAViCal is Free Software licensed under the General Public License.
>    - uses an SQL database for storage of event data
>    - supports backward-compatible access via WebDAV in read-only or read-write mode (not recommended)
>    - is committed to inter-operation with the widest possible CalDAV client software.
>
>DAViCal supports basic delegation of read/write access among calendar users, multiple users or clients reading and writing the same calendar entries over time, and scheduling of meetings with free/busy time displayed.
(*https://www.davical.org/*)

### Settings Added
- Exposed Ports: TCP 80 and TCP 443
- Exposed Volumes: /config and /var/lib/postgresql/data/
- Exposed Variables: TIME_ZONE and HOST_NAME and Locales (LC_ALL, LANG). There is a bug with DAVICAL_LANG for lang interface, I will fix it soon. Postgres keeps the language you choose
For other details go to the README of the original project: https://github.com/datze/davical

