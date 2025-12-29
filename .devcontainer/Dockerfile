FROM ubuntu:22.04

# Temel araçlar ve Flutter bağımlılıkları
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk wget \
    cmake ninja-build pkg-config libgtk-3-dev # Desktop desteği için

# Flutter SDK kurulumu
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Flutter ayarları
RUN flutter config --enable-web && flutter doctor