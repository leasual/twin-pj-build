# 使用Ubuntu作为基础镜像
FROM --platform=linux/amd64 ubuntu:22.04

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要的构建工具
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    python3-dev \
    automake \
    autoconf \
    libtool \
    pkg-config \
    yasm \
    nasm \
    git \
    wget \
    unzip \
    libpcre3-dev \
    bison \
    openjdk-17-jdk \
    curl \
    zip \
    cmake

# 安装SWIG
WORKDIR /tmp
RUN wget https://github.com/swig/swig/archive/refs/tags/v4.0.2.tar.gz && \
    tar -xzf v4.0.2.tar.gz && \
    cd swig-4.0.2 && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && \
    make install

# 设置Android SDK和NDK
WORKDIR /opt
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

# 下载并安装Android命令行工具
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm cmdline-tools.zip

# 接受许可证并安装SDK组件
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses && \
    ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# 下载NDK 18和21
RUN ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "ndk;18.1.5063045" "ndk;21.4.7075529"

# 设置环境变量
ENV ANDROID_NDK_HOME_18=${ANDROID_HOME}/ndk/18.1.5063045
ENV ANDROID_NDK_HOME_21=${ANDROID_HOME}/ndk/21.4.7075529
ENV ANDROID_NDK_HOME=${ANDROID_NDK_HOME_21}
ENV PATH=${PATH}:${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin

# 设置OpenSSL和OpenH264版本
ENV OPENSSL_VERSION=3.3.1
ENV OPENH264_VERSION=2.4.1

# 创建工作和输出目录
RUN mkdir -p /src/output/openssl/armeabi-v7a/lib \
    /src/output/openssl/armeabi-v7a/include \
    /src/output/openssl/arm64-v8a/lib \
    /src/output/openssl/arm64-v8a/include \
    /src/output/openh264/armeabi-v7a/lib \
    /src/output/openh264/armeabi-v7a/include \
    /src/output/openh264/arm64-v8a/lib \
    /src/output/openh264/arm64-v8a/include \
    /src/output/pjsip/armeabi-v7a \
    /src/output/pjsip/arm64-v8a \
    /src/output/pjsua2/jniLibs/armeabi-v7a \
    /src/output/pjsua2/jniLibs/arm64-v8a \
    /src/output/pjsua2/java/org/pjsip/pjsua2 \
    /src/libs

# 添加编译脚本
COPY build_libraries.sh /src/
RUN chmod +x /src/build_libraries.sh

# 设置工作目录
WORKDIR /src