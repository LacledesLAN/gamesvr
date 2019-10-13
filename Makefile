define clone-or-pull
    @echo "> Cloning/pulling $1 to ./repos/$2"
    @git clone "$1" "./repos/$2" 2> /dev/null || git -C "./repos/$2" checkout -- . && git -C "./repos/$2" pull --recurse-submodules
	@git -C "./repos/$2" submodule update --init --recursive;
	@echo ""
endef

define build
    @echo build
endef

define test
    @echo test
endef

define push
    @echo push
endef

.PHONY: pull-srcds-builder
pull-srcds-builder:
	@echo "> Pulling Docker image lacledeslan/steamcmd:linux"
	docker pull lacledeslan/steamcmd:linux
	@echo ""

.PHONY: pull-debian-stable-slim
pull-debian-stable-slim:
	@echo "> Pulling Docker image debian:stable-slim"
	docker pull debian:stable-slim
	@echo ""

##    _____  _____  _____  ____
##  / ____|/ ____|/ ____|/ __ \
## | |    | (___ | |  __| |  | |
## | |     \___ \| | |_ | |  | |
## | |____ ____) | |__| | |__| |
##  \_____|_____/ \_____|\____/

.PHONY: csgo
csgo: gamesvr-csgo gamesvr-csgo-freeplay gamesvr-csgo-test gamesvr-csgo-warmod gamesvr-csgo-warmod-hasty gamesvr-csgo-warmod-overtime
	@echo "fin"

.PHONY: csgo-push
csgo-push: csgo
	@echo "fin"
	docker push lacledeslan/gamesvr-csgo:latest
	docker push lacledeslan/gamesvr-csgo-freeplay:latest
	docker push lacledeslan/gamesvr-csgo-test:latest
	docker push lacledeslan/gamesvr-csgo-warmod:latest
	docker push lacledeslan/gamesvr-csgo-warmod:hasty
	docker push lacledeslan/gamesvr-csgo-warmod:overtime

.PHONY: gamesvr-csgo
gamesvr-csgo: pull-srcds-builder pull-debian-stable-slim
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-csgo,gamesvr-csgo)
	@echo "> Building Docker image lacledeslan/gamesvr-csgo:latest"
	@docker build ./repos/gamesvr-csgo -f ./repos/gamesvr-csgo/linux.Dockerfile -t lacledeslan/gamesvr-csgo --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-csgo:latest"
	@docker run -it --rm lacledeslan/gamesvr-csgo ./ll-tests/gamesvr-csgo.sh;
	@echo y | docker image prune > /dev/null 2>&1
	@echo ""

.PHONY: gamesvr-csgo-freeplay
gamesvr-csgo-freeplay: ##########################gamesvr-csgo
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-csgo-freeplay,gamesvr-csgo-freeplay)
	@echo "> Building Docker image lacledeslan/gamesvr-csgo-freeplay:latest"
	@docker build ./repos/gamesvr-csgo-freeplay -f ./repos/gamesvr-csgo-freeplay/Dockerfile.linux -t lacledeslan/gamesvr-csgo-freeplay --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-csgo-freeplay:latest"
	@docker run -it --rm lacledeslan/gamesvr-csgo-freeplay:latest ./ll-tests/gamesvr-csgo-freeplay.sh;
	@echo ""

.PHONY: gamesvr-csgo-test
gamesvr-csgo-test: ##########################gamesvr-csgo
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-csgo-test,gamesvr-csgo-test)
	@echo "> Building Docker image lacledeslan/gamesvr-csgo-test:latest"
	@docker build ./repos/gamesvr-csgo-test -f ./repos/gamesvr-csgo-test/Dockerfile.linux -t lacledeslan/gamesvr-csgo-test --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-csgo-test:latest"
	@docker run -it --rm lacledeslan/gamesvr-csgo-test:latest ./ll-tests/gamesvr-csgo-test.sh;
	@echo ""

.PHONY: gamesvr-csgo-warmod
gamesvr-csgo-warmod: ##########################gamesvr-csgo
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-csgo-warmod,gamesvr-csgo-warmod)
	@echo "> Building Docker image lacledeslan/gamesvr-csgo-warmod:latest"
	@docker build ./repos/gamesvr-csgo-warmod -f ./repos/gamesvr-csgo-warmod/linux.Dockerfile -t lacledeslan/gamesvr-csgo-warmod:latest --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-csgo-warmod:latest"
	@docker run -it --rm lacledeslan/gamesvr-csgo-warmod:latest ./ll-tests/gamesvr-csgo-warmod.sh;
	@echo ""

.PHONY: gamesvr-csgo-warmod-hasty
gamesvr-csgo-warmod-hasty: gamesvr-csgo-warmod
	@echo "> Building Docker image lacledeslan/gamesvr-csgo-warmod:hasty"
	@docker build ./repos/gamesvr-csgo-warmod -f ./repos/gamesvr-csgo-warmod/linux.hasty.Dockerfile -t lacledeslan/gamesvr-csgo-warmod:hasty --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-csgo-warmod:hasty"
	@docker run -it --rm lacledeslan/gamesvr-csgo-warmod:hasty ./ll-tests/gamesvr-csgo-warmod-hasty.sh;
	@echo ""

.PHONY: gamesvr-csgo-warmod-overtime
gamesvr-csgo-warmod-overtime: gamesvr-csgo-warmod
	@echo "> Building Docker image lacledeslan/gamesvr-csgo-warmod:overtime"
	@docker build ./repos/gamesvr-csgo-warmod -f ./repos/gamesvr-csgo-warmod/linux.overtime.Dockerfile -t lacledeslan/gamesvr-csgo-warmod:overtime --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-csgo-warmod:overtime"
	@docker run -it --rm lacledeslan/gamesvr-csgo-warmod:overtime ./ll-tests/gamesvr-csgo-warmod-overtime.sh;
	@echo ""

##  __  __ _                            __ _
## |  \/  (_)                          / _| |
## | \  / |_ _ __   ___  ___ _ __ __ _| |_| |_
## | |\/| | | '_ \ / _ \/ __| '__/ _` |  _| __|
## | |  | | | | | |  __/ (__| | | (_| | | | |_
## |_|  |_|_|_| |_|\___|\___|_|  \__,_|_|  \__|

.PHONY: minecraft
minecraft: gamesvr-minecarft gamesvr-minecarft-challenge1 gamesvr-minecarft-challenge2 gamesvr-minecarft-challenge3
	@echo "fin"

.PHONY: gamesvr-minecarft
gamesvr-minecarft:
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-minecraft,gamesvr-minecraft)
	@echo "> Building Docker image lacledeslan/gamesvr-minecraft:latest"
	@docker build ./repos/gamesvr-minecraft -f ./repos/gamesvr-minecraft/linux.Dockerfile -t lacledeslan/gamesvr-minecraft --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-minecraft:latest"
	@docker run -it --rm lacledeslan/gamesvr-minecraft ./ll-tests/gamesvr-minecraft.sh;
	@echo y | docker image prune > /dev/null 2>&1
	@echo ""

.PHONY: gamesvr-minecarft-challenge1
gamesvr-minecarft-challenge1:
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-minecraft-challenge1,gamesvr-minecraft-challenge1)
	@echo "> Building Docker image lacledeslan/gamesvr-minecraft-challenge1:latest"
	@docker build ./repos/gamesvr-minecraft-challenge1 -f ./repos/gamesvr-minecraft-challenge1/linux.Dockerfile -t lacledeslan/gamesvr-minecraft-challenge1 --no-cache;
	@echo y | docker image prune > /dev/null 2>&1
	@echo ""

.PHONY: gamesvr-minecarft-challenge2
gamesvr-minecarft-challenge2:
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-minecraft-challenge2,gamesvr-minecraft-challenge2)
	@echo "> Building Docker image lacledeslan/gamesvr-minecraft-challenge2:latest"
	@docker build ./repos/gamesvr-minecraft-challenge2 -f ./repos/gamesvr-minecraft-challenge2/linux.Dockerfile -t lacledeslan/gamesvr-minecraft-challenge2 --no-cache;
	@echo y | docker image prune > /dev/null 2>&1
	@echo ""

.PHONY: gamesvr-minecarft-challenge3
gamesvr-minecarft-challenge3:
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-minecraft-challenge3,gamesvr-minecraft-challenge3)
	@echo "> Building Docker image lacledeslan/gamesvr-minecraft-challenge3:latest"
	@docker build ./repos/gamesvr-minecraft-challenge3 -f ./repos/gamesvr-minecraft-challenge3/linux.Dockerfile -t lacledeslan/gamesvr-minecraft-challenge3 --no-cache;
	@echo y | docker image prune > /dev/null 3>&1
	@echo ""

.DEFAULT_GOAL := help
.PHONY: help
help:
	@echo "\nThis makefile is for building out Laclecde's LAN Game Servers; particularly those that can't be built in CI/CD cloud offerings.\n"
