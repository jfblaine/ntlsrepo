FROM aio.home.io:5000/ntlsrepo/httpd:latest

USER root

COPY index.html /var/www/html/

USER 1001
