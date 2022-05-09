
# Copyright (c) 2022 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

VERSION                := $(shell cat VERSION)
REGISTRY               := eu.gcr.io/gardener-project
PREFIX                 := alpine-iptables
ALPINE_IMAGE_REPOSITORY  := $(REGISTRY)/$(PREFIX)
ALPINE_IMAGE_TAG         := $(VERSION)

.PHONY: alpine-docker-image
alpine-docker-image:
	@docker build -t $(ALPINE_IMAGE_REPOSITORY):$(ALPINE_IMAGE_TAG) -f alpine/Dockerfile --rm .

.PHONY: docker-image
docker-image: alpine-docker-image

.PHONY: release
release: docker-image docker-login docker-push

.PHONY: docker-login
docker-login:
	@gcloud auth login

.PHONY: docker-push
docker-push:
	@if ! docker images $(ALPINE_IMAGE_REPOSITORY) | awk '{ print $$2 }' | grep -q -F $(ALPINE_IMAGE_TAG); then echo "$(ALPINE_IMAGE_REPOSITORY) version $(ALPINE_IMAGE_TAG) is not yet built. Please run 'make ALPINE-docker-image'"; false; fi
	@docker push $(ALPINE_IMAGE_REPOSITORY):$(ALPINE_IMAGE_TAG)

