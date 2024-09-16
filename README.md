# Docker image for build Android apps

This image  is based in OpenJDK 17 and contains the following tools:

- OpenJDK 17
- Gradle
- Maven
- Android SDK Manager
- Android Build Tools
- NVM (Node Version Manager)

## Tasks

### build

Build the image

Env: DOCKER=docker
Inputs: DOCKER
Interactive: true

```bash
export RELEASE=$(date +%Y%m%d%H%M)
$DOCKER build -t digiosysops/android-build:latest -t digiosysops/android-build:$RELEASE .
```

### push

Push the image to the registry

Env: DOCKER=docker
Inputs: DOCKER
Interactive: true

```bash
LAST_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "digiosysops/android-build:" | grep -v "latest" | sort -r | head -n 1)
$DOCKER push $LAST_IMAGE
$DOCKER push digiosysops/android-build:latest
```

### clean

Remove the image

Env: DOCKER=docker
Inputs: DOCKER
Interactive: true

```bash
$DOCKER rmi $(docker images --format "{{.Repository}}:{{.Tag}}" | grep "digiosysops/android-build:" | sort -r)
```

### build:ionic

Build the image

Env: DOCKER=docker
Inputs: DOCKER
Interactive: true

```bash
export RELEASE=$(date +%Y%m%d%H%M)
$DOCKER build -t digiosysops/android-build:ionic-latest -t digiosysops/android-build:ionic-$RELEASE --build-arg FINISHTASK=image:ionic .
```

### push:ionic

Push the image to the registry

Env: DOCKER=docker
Inputs: DOCKER
Interactive: true

```bash
LAST_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "digiosysops/android-build:ionic-" | grep -v "latest" | sort -r | head -n 1)
$DOCKER push $LAST_IMAGE
$DOCKER push digiosysops/android-build:ionic-latest
```

### image:android

An empty task to be used as a dependency

```bash
echo "Android image"
```

### image:ionic

An empty task to be used as a dependency

```bash
# Installing Node lts using fnm
fnm install --lts
eval "$(fnm env)"
# Installing Ionic
npm install -g @ionic/cli
```

Later use the following command before the rest node commands `eval "$(fnm env)"`

### image:reactnative

An empty task to be used as a dependency

```bash
echo "React Native image"
```
