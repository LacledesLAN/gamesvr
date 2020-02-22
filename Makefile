define clone-or-pull
    @echo "> Cloning/pulling $1 to ./repos/$2"
    @git clone "$1" "./repos/$2" 2> /dev/null || git -C "./repos/$2" checkout -- . && git -C "./repos/$2" pull --recurse-submodules
	@git -C "./repos/$2" submodule update --init --recursive;
	@echo ""
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

.PHONY: pull-debian-stretch-slim
pull-debian-stretch-slim:
	@echo "> Pulling Docker image debian:stretch-slim"
	docker pull debian:stretch-slim
	@echo ""

.PHONY: purge-images
purge-images:
	@echo "> Removing ALL local Docker images with the `lacledeslan` repository tag"
	docker images -a | grep "lacledeslan/" | awk '{print $3}' | xargs docker rmi

##  ____  _            _
## |  _ \| |          | |
## | |_) | | __ _  ___| | ___ __ ___   ___  ___  __ _
## |  _ <| |/ _` |/ __| |/ / '_ ` _ \ / _ \/ __|/ _` |
## | |_) | | (_| | (__|   <| | | | | |  __/\__ \ (_| |
## |____/|_|\__,_|\___|_|\_\_| |_| |_|\___||___/\__,_|

.PHONY: blackmesa
blackmesa: gamesvr-blackmesa gamesvr-blackmesa-freeplay
	@echo "fin"

.PHONY: blackmesa-push
blackmesa-push: blackmesa
	@echo "fin"
	docker push lacledeslan/gamesvr-blackmesa:latest
	docker push lacledeslan/gamesvr-blackmesa-freeplay:latest

.PHONY: gamesvr-blackmesa
gamesvr-blackmesa: pull-srcds-builder pull-debian-stretch-slim
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-blackmesa,gamesvr-blackmesa)
	@echo "> Building Docker image lacledeslan/gamesvr-blackmesa:latest"
	@docker build ./repos/gamesvr-blackmesa -f ./repos/gamesvr-blackmesa/linux.Dockerfile -t lacledeslan/gamesvr-blackmesa --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-blackmesa:latest"
	@docker run -it --rm lacledeslan/gamesvr-blackmesa ./ll-tests/gamesvr-blackmesa.sh;
	@echo y | docker image prune > /dev/null 2>&1
	@echo ""

.PHONY: gamesvr-blackmesa-freeplay
gamesvr-blackmesa-freeplay: ##########################gamesvr-blackmesa
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-blackmesa-freeplay,gamesvr-blackmesa-freeplay)
	@echo "> Building Docker image lacledeslan/gamesvr-blackmesa-freeplay:latest"
	@docker build ./repos/gamesvr-blackmesa-freeplay -f ./repos/gamesvr-blackmesa-freeplay/Dockerfile.linux -t lacledeslan/gamesvr-blackmesa-freeplay --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-blackmesa-freeplay:latest"
	@docker run -it --rm lacledeslan/gamesvr-blackmesa-freeplay:latest ./ll-tests/gamesvr-blackmesa-freeplay.sh;
	@echo ""

##    _____  _____  _____  ____
##  / ____|/ ____|/ ____|/ __ \
## | |    | (___ | |  __| |  | |
## | |     \___ \| | |_ | |  | |
## | |____ ____) | |__| | |__| |
##  \_____|_____/ \_____|\____/

.PHONY: csgo
csgo: gamesvr-csgo gamesvr-csgo-freeplay gamesvr-csgo-test gamesvr-csgo-tourney gamesvr-csgo-warmod
	@echo "fin"

.PHONY: csgo-push
csgo-push: csgo
	@echo "fin"
	docker push lacledeslan/gamesvr-csgo:latest
	docker push lacledeslan/gamesvr-csgo-freeplay:latest
	docker push lacledeslan/gamesvr-csgo-test:latest
	docker push lacledeslan/gamesvr-csgo-tourney:latest
	docker push lacledeslan/gamesvr-csgo-tourney:overtime
	docker push lacledeslan/gamesvr-csgo-tourney:get5
	docker push lacledeslan/gamesvr-csgo-tourney:hasty
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

.PHONY: gamesvr-csgo-tourney
gamesvr-csgo-tourney: ##########################gamesvr-csgo
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-csgo-tourney,gamesvr-csgo-tourney)
	@docker build ./repos/gamesvr-csgo-tourney -f ./repos/gamesvr-csgo-tourney/linux.Dockerfile -t lacledeslan/gamesvr-csgo-tourney:latest --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-csgo-tourney:latest"
	@docker run -it --rm lacledeslan/gamesvr-csgo-tourney:latest ./ll-tests/gamesvr-csgo-tourney.sh;
	@echo ""
	@echo ""
	@docker build ./repos/gamesvr-csgo-tourney -f ./repos/gamesvr-csgo-tourney/linux.get5.Dockerfile -t lacledeslan/gamesvr-csgo-tourney:get5 --no-cache --build-arg BUILDNODE=$env:computername;
	##@echo "> Running tests on lacledeslan/gamesvr-csgo-tourney:latest"
	##@docker run -it --rm lacledeslan/gamesvr-csgo-tourney:latest ./ll-tests/gamesvr-csgo-tourney.sh;
	@echo ""
	@echo ""
	@docker build ./repos/gamesvr-csgo-tourney -f ./repos/gamesvr-csgo-tourney/linux.hasty.Dockerfile -t lacledeslan/gamesvr-csgo-tourney:hasty --no-cache --build-arg BUILDNODE=$env:computername;
	##@echo "> Running tests on lacledeslan/gamesvr-csgo-tourney:latest"
	##@docker run -it --rm lacledeslan/gamesvr-csgo-tourney:latest ./ll-tests/gamesvr-csgo-tourney.sh;
	@echo ""
	@echo ""
	@docker build ./repos/gamesvr-csgo-tourney -f ./repos/gamesvr-csgo-tourney/linux.overtime.Dockerfile -t lacledeslan/gamesvr-csgo-tourney:overtime --no-cache --build-arg BUILDNODE=$env:computername;
	##@echo "> Running tests on lacledeslan/gamesvr-csgo-tourney:latest"
	##@docker run -it --rm lacledeslan/gamesvr-csgo-tourney:latest ./ll-tests/gamesvr-csgo-tourney.sh;
	@echo ""
	@echo ""

.PHONY: gamesvr-csgo-warmod
gamesvr-csgo-warmod: ##########################gamesvr-csgo
	$(call clone-or-pull,https://github.com/LacledesLAN/gamesvr-csgo-warmod,gamesvr-csgo-warmod)
	@echo "> Building Docker image lacledeslan/gamesvr-csgo-warmod:latest"
	@docker build ./repos/gamesvr-csgo-warmod -f ./repos/gamesvr-csgo-warmod/linux.Dockerfile -t lacledeslan/gamesvr-csgo-warmod:latest --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-csgo-warmod:latest"
	@docker run -it --rm lacledeslan/gamesvr-csgo-warmod:latest ./ll-tests/gamesvr-csgo-warmod.sh;
	@echo ""
	@echo ""
	@echo "> Building Docker image lacledeslan/gamesvr-csgo-warmod:hasty"
	@docker build ./repos/gamesvr-csgo-warmod -f ./repos/gamesvr-csgo-warmod/linux.hasty.Dockerfile -t lacledeslan/gamesvr-csgo-warmod:hasty --no-cache --build-arg BUILDNODE=$env:computername;
	@echo "> Running tests on lacledeslan/gamesvr-csgo-warmod:hasty"
	@docker run -it --rm lacledeslan/gamesvr-csgo-warmod:hasty ./ll-tests/gamesvr-csgo-warmod-hasty.sh;
	@echo ""
	@echo ""
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
