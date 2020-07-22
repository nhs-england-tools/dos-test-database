PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(abspath $(PROJECT_DIR)/build/automation/init.mk)

# ==============================================================================
# Project targets: Dev workflow

download: project-config # Download DoS database dump file
	[ -f build/docker/data/assets/data/50-dos-database-dump.sql.gz ] && exit 0
	eval $$(make aws-assume-role-export-variables)
	make aws-s3-download \
		URI=nhsd-texasplatform-service-dos-lk8s-nonprod/dos-pg-dump-$(DOS_DATABASE_VERSION)-clean-PU.sql.gz \
		FILE=build/docker/data/assets/data/50-dos-database-dump.sql.gz

build: project-config # Build DoS database image
	make docker-build NAME=data
	make docker-build NAME=database

start: project-start # Start service locally

stop: project-stop # Stop service locally

log: project-log # Print service logs

# ==============================================================================
# Project targets: Ops workflow

image: # Create data and database images from the dump file and push them to the registry
	make \
		image-create \
		image-push

instance: # Create an instance and populate it from the existing data image - optional: VERSION=[version or tag of the data image, defaults to the just built image],NAME=[instance name, defaults to "test"]
	make \
		instance-create \
		instance-populate

clean: # Remove all the resources - optional: NAME=[instance name, defaults to "test"]
	make k8s-undeploy-job \
		STACK=data \
		PROFILE=dev
	make instance-destroy
	rm -fv build/docker/data/assets/data/*.sql.gz

# ==============================================================================
# Supporting targets and variables

PSQL := docker exec --interactive $(_TTY) database psql -d postgres -U postgres -t -c

image-create: download # Create data and database images
	make \
		build \
		stop \
		start \
		_image-create-wait \
		_image-create-snapshot

_image-create-wait:
	docker logs --follow data &
	while true; do
		sleep 1
		exists=$$($(PSQL) "select to_regclass('_metadata')" 2> /dev/null | tr -d '[:space:]')
		if [ -n "$$exists" ]; then
			count=$$($(PSQL) "select count(*) from _metadata where label = 'created'" 2> /dev/null | tr -d '[:space:]')
			if [ "$$count" -eq 1 ]; then
				break
			fi
		fi
	done

_image-create-snapshot:
	docker stop database
	docker commit database $(DOCKER_REGISTRY)/database:$$(cat build/docker/database/.version)
	docker tag $(DOCKER_REGISTRY)/database:$$(cat build/docker/database/.version) $(DOCKER_REGISTRY)/database:latest
	docker rm --force --volumes database

image-create-repository: # Create registry for the data and database images
	make docker-create-repository NAME=data 2> /dev/null ||:
	make docker-create-repository NAME=database 2> /dev/null ||:

image-push: # Push the data and database images to the registry
	make docker-push NAME=data VERSION=$$(cat build/docker/data/.version)
	make docker-push NAME=database VERSION=$$(cat build/docker/database/.version)

instance-plan: # Show the creation instance plan - optional: NAME=[instance name, defaults to "test"]
	make terraform-plan \
		PROFILE=dev \
		NAME=$(or $(NAME), test)

instance-create: project-config # Create an instance - optional: NAME=[instance name, defaults to "test"]
	make terraform-apply-auto-approve \
		PROFILE=dev \
		NAME=$(or $(NAME), test)
	make aws-rds-describe-instance \
		PROFILE=dev \
		NAME=$(or $(NAME), test)

instance-destroy: # Destroy the instance - optional: NAME=[instance name, defaults to "test"]
	make terraform-destroy-auto-approve \
		PROFILE=dev \
		NAME=$(or $(NAME), test)

instance-populate: # Populate the instance with the data - optional: NAME=[instance name, defaults to "test"],VERSION=[version or tag of the data image, defaults to the just built image]
	eval "$$(make secret-fetch-and-export-variables NAME=uec-dos-api-tdb-test-dev/deployment)"
	make k8s-deploy-job \
		STACK=data \
		SECONDS=600 \
		PROFILE=dev \
		NAME=$(or $(NAME), test) \
		VERSION=$(or $(VERSION), $$(cat build/docker/data/.version))

# ==============================================================================

.SILENT:
