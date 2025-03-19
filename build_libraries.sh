#!/bin/bash
set -e

# 设置目录
WORKSPACE="/src"
OUTPUT_DIR="${WORKSPACE}/output"
LIBS_DIR="${WORKSPACE}/libs"

# 构建OpenSSL
build_openssl() {
    echo "=== 开始构建OpenSSL ${OPENSSL_VERSION} ==="
    cd ${LIBS_DIR}
    
    if [ ! -f "openssl-${OPENSSL_VERSION}.tar.gz" ]; then
        wget -q https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
    fi
    
    if [ ! -d "openssl-${OPENSSL_VERSION}" ]; then
        tar -xzf openssl-${OPENSSL_VERSION}.tar.gz
    fi
    
    cd openssl-${OPENSSL_VERSION}
    
    # 确保工作空间bin目录存在
    mkdir -p ${WORKSPACE}/bin
    chmod 755 ${WORKSPACE}/bin
    
    # 为两种架构构建OpenSSL
    for ABI in armeabi-v7a arm64-v8a; do
        echo "Building OpenSSL for $ABI"
        case $ABI in
            armeabi-v7a)
                OPENSSL_ARCH="android-arm"
                API_LEVEL=19
                ;;
            arm64-v8a)
                OPENSSL_ARCH="android-arm64"
                API_LEVEL=21
                ;;
        esac
        
        # 创建构建目录
        mkdir -p ${LIBS_DIR}/openssl-build/$ABI
        
        # 设置环境变量
        export PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
        export ANDROID_NDK_ROOT=${ANDROID_NDK_HOME}
        
        # 为NDK 21创建符号链接
        if [[ "$ABI" == "armeabi-v7a" ]]; then
            ln -sf ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi${API_LEVEL}-clang ${WORKSPACE}/bin/arm-linux-androideabi-gcc
            export PATH=${WORKSPACE}/bin:$PATH
        elif [[ "$ABI" == "arm64-v8a" ]]; then
            ln -sf ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android${API_LEVEL}-clang ${WORKSPACE}/bin/aarch64-linux-android-gcc
            export PATH=${WORKSPACE}/bin:$PATH
        fi
        
        # 配置OpenSSL
        if [[ "$ABI" == "armeabi-v7a" ]]; then
            # 为32位ARMv7架构添加no-asm选项
            ./Configure $OPENSSL_ARCH -D__ANDROID_API__=$API_LEVEL --prefix=${LIBS_DIR}/openssl-build/$ABI no-asm
        else
            # arm64-v8a架构不需要添加no-asm
            ./Configure $OPENSSL_ARCH -D__ANDROID_API__=$API_LEVEL --prefix=${LIBS_DIR}/openssl-build/$ABI
        fi
        
        # 构建静态库
        make -j$(nproc) clean
        make -j$(nproc)
        make install_sw
        
        # 将构建结果复制到输出目录
        cp -r ${LIBS_DIR}/openssl-build/$ABI/lib/* ${OUTPUT_DIR}/openssl/$ABI/lib/
        cp -r ${LIBS_DIR}/openssl-build/$ABI/include/* ${OUTPUT_DIR}/openssl/$ABI/include/
    done
    
    echo "OpenSSL构建完成"
}

# 构建OpenH264
build_openh264() {
    echo "=== 开始构建OpenH264 ${OPENH264_VERSION} ==="
    cd ${LIBS_DIR}
    
    # 克隆OpenH264源代码
    if [ ! -d "openh264-${OPENH264_VERSION}" ]; then
        git clone -b v${OPENH264_VERSION} --depth 1 https://github.com/cisco/openh264.git openh264-${OPENH264_VERSION}
    fi
    
    cd openh264-${OPENH264_VERSION}
    
    # 为每个架构构建OpenH264
    for ABI in armeabi-v7a arm64-v8a; do
        echo "Building OpenH264 for $ABI"
        
        # 设置构建目标目录
        INSTALL_DIR=${OUTPUT_DIR}/openh264/$ABI
        
        # 设置正确的构建参数
        if [[ "$ABI" == "armeabi-v7a" ]]; then
            ARCH=arm
            API_LEVEL=19
            TOOLCHAINPREFIX=arm-linux-androideabi
            NDKARCH=armv7a-linux-androideabi
        else
            ARCH=arm64
            API_LEVEL=21
            TOOLCHAINPREFIX=aarch64-linux-android
            NDKARCH=aarch64-linux-android
        fi
        
        # 设置环境变量
        export ARCH=$ARCH
        export OS=android
        export NDKROOT=${ANDROID_NDK_HOME}
        export TARGET=android-$API_LEVEL
        export NDKLEVEL=$API_LEVEL
        export NDK_TOOLCHAIN_VERSION=clang
        
        # 清理
        make clean OS=android ARCH=$ARCH TARGET=android-$API_LEVEL NDKROOT=$NDKROOT NDKLEVEL=$API_LEVEL NDK_TOOLCHAIN_VERSION=clang
        
        # 构建和安装
        make install OS=android ARCH=$ARCH TARGET=android-$API_LEVEL NDKROOT=$NDKROOT NDKLEVEL=$API_LEVEL NDK_TOOLCHAIN_VERSION=clang PREFIX=$INSTALL_DIR -j$(nproc)
        
        # 验证安装结果
        echo "OpenH264安装结果:"
        find $INSTALL_DIR -type f | sort
        
        # 创建pkgconfig目录和文件
        mkdir -p $INSTALL_DIR/lib/pkgconfig
        
        cat > $INSTALL_DIR/lib/pkgconfig/openh264.pc << EOF
prefix=$INSTALL_DIR
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: OpenH264
Description: OpenH264 is a codec library which supports H.264 encoding and decoding
Version: ${OPENH264_VERSION}
Libs: -L\${libdir} -lopenh264
Cflags: -I\${includedir}
EOF
    done
    
    echo "OpenH264构建完成"
}

# 主函数
main() {
    build_openssl
    build_openh264
    
    # 移除所有.so文件，只保留.a文件
    find ${OUTPUT_DIR}/openssl -name "*.so" -delete
    find ${OUTPUT_DIR}/openh264 -name "*.so" -delete
    
    # 确认只有静态库存在
    echo "确认OpenSSL目录中的库文件:"
    find ${OUTPUT_DIR}/openssl -name "lib*.a" | sort
    
    echo "确认OpenH264目录中的库文件:"
    find ${OUTPUT_DIR}/openh264 -name "lib*.a" | sort
    
    echo "所有库构建完成"
}

# 执行主函数
main