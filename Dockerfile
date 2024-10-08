FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu
# Is derivated from Ubuntu22.04 not the official openjdk image depending on Debian 11

ARG FINISHTASK=image:android

USER root

# update the repository sources list
# and install dependencies
RUN apt-get update \
    && apt-get install -y curl wget unzip \
    && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/*

# ========== INSTALL ANDROID SDK TOOLS ==========

ENV ANDROID_HOME /opt/android-sdk-linux

# ------------------------------------------------------
# --- Install required tools

# Dependencies to execute Android builds
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386 || apt-get install -f && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME
#https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN cd /opt && wget -q https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip -O android-sdk-tools.zip && \
    unzip -q android-sdk-tools.zip && mkdir -p ${ANDROID_HOME} && mv cmdline-tools/ ${ANDROID_HOME}/tools/ && \
    rm -f android-sdk-tools.zip

# ndk-bundle
#RUN cd $ANDROID_HOME && wget -q https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.zip -O ndk-bundle.zip && \
#    unzip -q ndk-bundle.zip && mv android-ndk-r10e ndk-bundle && chown -R jenkins:jenkins ndk-bundle/


ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
# Accept licenses before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file

# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN yes | sdkmanager --licenses --sdk_root=$ANDROID_HOME

# Platform tools
RUN sdkmanager "platform-tools" --sdk_root=$ANDROID_HOME

# Emulator
# RUN sdkmanager "emulator"
# For now we'll keep using 26.1.2 ; 26.1.3 had some booting issues...
RUN cd /opt \
    && wget https://dl.google.com/android/repository/emulator-linux-4077558.zip -O emulator.zip \
    && unzip -q emulator.zip -d ${ANDROID_HOME} \
    && rm emulator.zip

# Please keep all sections in descending order!
# list all platforms, sort them in descending order, take the newest 8 versions and install them
#RUN yes | sdkmanager --sdk_root=$ANDROID_HOME $( sdkmanager --sdk_root=$ANDROID_HOME --list 2>/dev/null| grep platforms | awk -F' ' '{print $1}' | sort -nr -k2 -t- | head -3 )
# list all build-tools, sort them in descending order and install them
#RUN yes | sdkmanager --sdk_root=$ANDROID_HOME $( sdkmanager --sdk_root=$ANDROID_HOME  --list 2>/dev/null| grep build-tools | awk -F' ' '{print $1}' | sort -nr -k2 -t\; | uniq )
#RUN yes | sdkmanager --sdk_root=$ANDROID_HOME "extras;android;m2repository" \
#    "extras;google;m2repository" \
#    "extras;google;google_play_services" \
#    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
#    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
#    "add-ons;addon-google_apis-google-23" \
#    "add-ons;addon-google_apis-google-22" \
#    "add-ons;addon-google_apis-google-21"

# ------------------------------------------------------
# --- Install Gradle from PPA

# Gradle PPA
RUN apt-get update && \
    apt-get -y install gradle && \
    gradle -v && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------
# --- Install Maven 3 from PPA

RUN apt-get -y purge maven && \
    apt-get update && \
    apt-get -y install maven && \
    mvn --version && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp/ && curl -sO https://github.com/google/bundletool/releases/download/1.15.6/bundletool-all-1.15.6.jar && mv bundletool-all-1.15.6.jar /usr/bin/bundletool.jar

# ========== INSTALL NODE TOOLS ==========
# nvm environment variables
# ENV NVM_DIR /usr/local/nvm
# ENV NODE_VERSION 8.3.0

# install nvm
# https://github.com/creationix/nvm#install-script
# RUN mkdir -p /usr/local/nvm && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install node version
# RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
# RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
# RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
# ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin/:${PATH}"
# RUN ["/bin/bash", "-c", "node --version"]
# RUN ["/bin/bash", "-c","npm --version"]

# add node and npm to path so the commands are available
# ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
# ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# =========== INSTALL STEW BINARY MANAGER ==============
# Download stew binary manager from apk and remove the apk
RUN curl -L https://github.com/marwanhawari/stew/releases/download/v0.4.0/stew_0.4.0_linux_amd64.deb -o stew_0.4.0_linux_amd64.deb && \
    dpkg -i stew_0.4.0_linux_amd64.deb && \
    rm stew_0.4.0_linux_amd64.deb

COPY stew.config.json Stewfile.lock.json /root/

RUN mkdir -p $HOME/.config/stew && \
    mkdir -p $HOME/.local/share/stew && \
    mv $HOME/stew.config.json $HOME/.config/stew/ && \
    mv $HOME/Stewfile.lock.json $HOME/.local/share/stew/ && \
    stew install $HOME/.local/share/stew/Stewfile.lock.json && \
    rm -rf $HOME/.local/share/stew/pkg

COPY README.md /root/
RUN cd /root/ && xc ${FINISHTASK}

# ==================================
CMD bitrise -version
