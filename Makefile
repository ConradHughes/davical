SHELL:=/bin/bash
SAFE_STDOUT_TO_TGT=> $@ || ( rm -f $@ ; false )

include config.mkf
ifndef local_root
$(error Need to set local_root in config.mkf (see README.md).)
endif
ifndef d_username
$(error Need to set d_username in config.mkf (see README.md).)
endif
ifndef d_imagename
$(error Need to set d_imagename in config.mkf (see README.md).)
endif
ifndef l_imagename
$(error Need to set l_imagename in config.mkf (see README.md).)
endif
ifndef hostname
$(error Need to set hostname in config.mkf (see README.md).)
endif
ifndef timezone
$(error Need to set timezone in config.mkf (see README.md).)
endif
ifndef certdir
$(error Need to set certdir in config.mkf (see README.md).)
endif

pubcert:=$(certdir)/cert.pem
ifeq ($(wildcard $(pubcert)),)
$(error Public certificate $(pubcert) is missing.)
endif
pubcert:=$(certdir)/privkey.pem
ifeq ($(wildcard $(privkey)),)
$(error Private key $(privkey) is missing.)
endif
fullchain:=$(certdir)/fullchain.pem
ifeq ($(wildcard $(fullchain)),)
$(error Private key $(fullchain) is missing.)
endif

all:
	@echo 'No default target; try build, run, login, stop or clean.'

build:
	docker build -t $(d_username)/$(d_imagename) .
#	docker scan $(d_username)/$(d_imagename)

# Pre-run setup, to run on docker host: make local root and install cert
# keys.
$(localroot):
	mkdir -p $(addprefix $(local_root)/,config/ssl data log/apache2)
	cp $(pubcert) $(privkey) $(fullchain) $(local_root)/config/ssl


# Could have -p 8080:80, but I don't like HTTP.
run: $(local_root)
	docker run --name $(l_imagename) -p 8443:443 \
	    -v $(local_root)/config:/config \
	    -v $(local_root)/data:/var/lib/postgresql/data \
	    -v $(local_root)/log:/var/log \
	    -e HOST_NAME='$(hostname)' \
	    -e TIME_ZONE='$(timezone)' \
	    $(d_username)/$(d_imagename)

login:
	docker exec -it $(l_imagename) /bin/bash

stop:
	docker stop $(l_imagename)

save: $(l_imagename).tar.xz

$(l_imagename).tar.xz: Dockerfile
	docker image save $(d_username)/$(d_imagename) | xz $(SAFE_STDOUT_TO_TGT)

clean:
	docker container prune # Clear up stopped containers
	docker system prune    # Clears up unknown other stuff
	docker rmi $$(docker images -a -q)
