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

```bash
podman build -t android-build .
podman tag android-build digiosysops/android-build:latest
```

### push

Push the image to the registry

```bash
podman push digiosysops/android-build:latest
```

### clean

Remove the image

```bash
podman system prune -a
```
