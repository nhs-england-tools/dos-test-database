PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(abspath $(PROJECT_DIR)/build/automation/init.mk)

# ==============================================================================
# Development workflow targets

download: project-config # Download DoS database dump file
	[ -f build/docker/data/assets/data/50-dos-database-dump.sql.gz ] && exit 0
	eval $$(make aws-assume-role-export-variables)
	make aws-s3-download \
		URI=nhsd-texasplatform-service-dos-lk8s-nonprod/dos-pg-dump-$(DOS_DATABASE_VERSION)-clean-PU.sql.gz \
		FILE=build/docker/data/assets/data/50-dos-database-dump.sql.gz
	make _fix

_fix:
	cd build/docker/data/assets/data
	gunzip 50-dos-database-dump.sql.gz
	sed -i "s/SET default_tablespace = pathwaysdos_index_01;//g" 50-dos-database-dump.sql
	gzip 50-dos-database-dump.sql

build: project-config # Build DoS database image
	make docker-build NAME=data

start: # Start service locally
	docker volume rm --force "data" 2> /dev/null ||:
	docker volume create --name "data"
	make project-start

stop: # Stop service locally
	make project-stop
	docker volume rm --force "data" 2> /dev/null ||:

log: project-log # Print service logs

# --------------------------------------

image: # Create data and database images from the dump file and push them to the registry
	make \
		image-create \
		image-test \
		image-push

instance: # Create an instance and populate it from the existing data image - optional: VERSION=[version or tag of the data image, defaults to the just built image],DB_NAME_SUFFIX=[instance name suffix, defaults to "test"]
	make \
		instance-create \
		instance-populate

clean: # Remove all the resources - optional: DB_NAME_SUFFIX=[instance name suffix, defaults to "test"]
	rm -fv build/docker/data/assets/data/*.sql.gz
	rm -rf $(TMP_DIR)/*
	make k8s-undeploy-job \
		STACK=data \
		PROFILE=dev
	make instance-destroy

# --------------------------------------

PSQL := docker exec --interactive $(_TTY) database psql -d postgres -U postgres -t -c

image-create: stop # Create data and database images
	make \
		download \
		build \
		start \
		_image-create-wait \
		_image-create-snapshot \
		stop

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
	docker run --interactive $(_TTY) --rm \
		--volume data:/var/lib/postgresql/data \
		--volume $(TMP_DIR):/project \
		alpine:$(DOCKER_ALPINE_VERSION) \
			sh -exc "cd /var/lib/postgresql/data; tar -czf /project/backup.tar.gz ."
	docker cp $(TMP_DIR)/backup.tar.gz database:/var/lib/postgresql/backup.tar.gz
	docker commit database $(DOCKER_REGISTRY)/database:$$(cat build/docker/data/.version)
	docker tag $(DOCKER_REGISTRY)/database:$$(cat build/docker/data/.version) $(DOCKER_REGISTRY)/database:latest

image-test: # Test database image
	docker run --interactive $(_TTY) --detach --rm \
		--name database \
		$(DOCKER_REGISTRY)/database:$$(cat build/docker/data/.version) \
		postgres
	docker logs --follow database &
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
	docker rm --force database

image-create-repository: # Create registry for the data and database images
	make docker-create-repository \
		NAME=data \
		POLICY_FILE=build/automation/lib/aws/aws-ecr-create-repository-policy-custom.json \
		2> /dev/null ||:
	make docker-create-repository \
		NAME=database \
		POLICY_FILE=build/automation/lib/aws/aws-ecr-create-repository-policy-custom.json \
		2> /dev/null ||:

image-push: # Push the data and database images to the registry
	make docker-push NAME=data VERSION=$$(cat build/docker/data/.version)
	make docker-push NAME=database VERSION=$$(cat build/docker/data/.version)

# --------------------------------------

instance-plan: # Show the creation instance plan - mandatory: PROFILE=[profile name] optional: DB_NAME_SUFFIX=[instance name suffix, defaults to "test"]
	[ $(PROFILE) == local ] && exit 1
	eval "$$(make secret-fetch-and-export-variables NAME=$(PROJECT_GROUP_SHORT)-$(PROJECT_NAME_SHORT)-dev/deployment)"
	make terraform-plan DB_NAME_SUFFIX=$(or $(DB_NAME_SUFFIX), test)

instance-create: project-config # Create an instance - mandatory: PROFILE=[profile name] optional: DB_NAME_SUFFIX=[instance name suffix, defaults to "test"]
	[ $(PROFILE) == local ] && exit 1
	eval "$$(make secret-fetch-and-export-variables NAME=$(PROJECT_GROUP_SHORT)-$(PROJECT_NAME_SHORT)-dev/deployment)"
	make terraform-apply-auto-approve DB_NAME_SUFFIX=$(or $(DB_NAME_SUFFIX), test)
	make aws-rds-describe-instance DB_NAME_SUFFIX=$(or $(DB_NAME_SUFFIX), test)

instance-destroy: # Destroy the instance - mandatory: PROFILE=[profile name] optional: DB_NAME_SUFFIX=[instance name suffix, defaults to "test"]
	[ $(PROFILE) == local ] && exit 1
	eval "$$(make secret-fetch-and-export-variables NAME=$(PROJECT_GROUP_SHORT)-$(PROJECT_NAME_SHORT)-dev/deployment)"
	make terraform-destroy-auto-approve DB_NAME_SUFFIX=$(or $(DB_NAME_SUFFIX), test)

instance-populate: # Populate the instance with the data - mandatory: PROFILE=[profile name] optional: DB_NAME_SUFFIX=[instance name suffix, defaults to "test"],VERSION=[version or tag of the data image, defaults to the just built image]
	[ $(PROFILE) == local ] && exit 1
	eval "$$(make secret-fetch-and-export-variables NAME=$(PROJECT_GROUP_SHORT)-$(PROJECT_NAME_SHORT)-dev/deployment)"
	make k8s-deploy-job \
		STACK=data \
		SECONDS=600 \
		DB_NAME_SUFFIX=$(or $(DB_NAME_SUFFIX), test) \
		VERSION=$(or $(VERSION), $$(cat build/docker/data/.version))

# ==============================================================================
# Supporting targets

trust-certificate: ssl-trust-certificate-project ## Trust the SSL development certificate

# ==============================================================================

.PHONY: \
	image-create \
	stop
