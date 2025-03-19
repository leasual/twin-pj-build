要将build_libraries.sh脚本放入Docker镜像并从容器中取出编译好的文件，你可以按照以下步骤操作：
放入build_libraries.sh脚本

创建目录结构：
在你的主机上，创建一个工作目录，比如pjsip-build，并在其中保存Dockerfile和build_libraries.sh：
mkdir -p pjsip-build
cd pjsip-build

创建和保存脚本：
将我提供的build_libraries.sh内容保存到这个目录中：
bashCopy# 使用你喜欢的编辑器创建脚本
vim build_libraries.sh   # 或者使用其他编辑器

# 粘贴脚本内容并保存

# 确保脚本有执行权限
chmod +x build_libraries.sh

创建Dockerfile：
同样在这个目录下创建Dockerfile文件，内容就是我之前提供的。

构建和运行Docker镜像

构建镜像：
docker build --platform=linux/amd64 -t pjsip-builder .
这里--platform=linux/amd64确保在Mac M系列芯片上使用Rosetta 2构建x86_64容器。
运行容器：
docker run --platform=linux/amd64 -it -v $(pwd):/host pjsip-builder /bin/bash
这里的-v $(pwd):/host会把当前目录挂载到容器内的/host目录，便于文件交换。

编译库并取出文件

在容器内执行编译脚本：
cd /src
./build_libraries.sh

将编译好的文件复制到挂载目录：
在容器内执行：
# 创建输出目录
mkdir -p /host/output

# 复制编译好的文件
cp -r /src/output/* /host/output/

退出容器：
exit

这样你就能在当前目录的output文件夹中看到所有编译好的库文件和头文件，可以用于后续的PJSIP编译或直接在Android项目中使用。

export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME_21 

编译pjsip android:

APP_PLATFORM=android-21 TARGET_ABI=armeabi-v7a ./configure-android --use-ndk-cflags --with-openh264=/src/output/openh264/armeabi-v7a --with-ssl=/src/output/openssl/armeabi-v7a --disable-android-mediacodec

APP_PLATFORM=android-21 TARGET_ABI=arm64-v8a ./configure-android --use-ndk-cflags --with-openh264=/src/output/openh264/arm64-v8a --with-ssl=/src/output/openssl/arm64-v8a --disable-android-mediacodec


编译iOS

ARCH="-arch arm64" MIN_IOS="-miphoneos-version-min=8.0" LDFLAGS="${LDFLAGS} -L/usr/lib -lstdc++ -lz -lc" ./configure-iphone --with-openh264=/Users/james/DigiDES-PJSIP/libs/openh264-2.4.1 --with-ssl=/Users/james/DigiDES-PJSIP/libs/openssl-3.3.1

cp ./pjmedia/lib/libpjmedia-arm64-apple-darwin_ios.a ./pjmedia/lib/libpjmedia-audiodev-arm64-apple-darwin_ios.a ./pjmedia/lib/libpjsdp-arm64-apple-darwin_ios.a ./pjmedia/lib/libpjmedia-videodev-arm64-apple-darwin_ios.a ./pjmedia/lib/libpjmedia-codec-arm64-apple-darwin_ios.a ./pjsip/lib/libpjsua2-arm64-apple-darwin_ios.a ./pjsip/lib/libpjsip-arm64-apple-darwin_ios.a ./pjsip/lib/libpjsip-ua-arm64-apple-darwin_ios.a ./pjsip/lib/libpjsua-arm64-apple-darwin_ios.a ./pjsip/lib/libpjsip-simple-arm64-apple-darwin_ios.a ./pjlib/lib/libpj-arm64-apple-darwin_ios.a ./pjlib-util/lib/libpjlib-util-arm64-apple-darwin_ios.a ./third_party/lib/libsrtp-arm64-apple-darwin_ios.a ./third_party/lib/libspeex-arm64-apple-darwin_ios.a ./third_party/lib/libyuv-arm64-apple-darwin_ios.a ./third_party/lib/libg7221codec-arm64-apple-darwin_ios.a ./third_party/lib/libgsmcodec-arm64-apple-darwin_ios.a ./third_party/lib/libwebrtc-arm64-apple-darwin_ios.a ./third_party/lib/libilbccodec-arm64-apple-darwin_ios.a ./third_party/lib/libresample-arm64-apple-darwin_ios.a ./pjnath/lib/libpjnath-arm64-apple-darwin_ios.a /Users/james/DigiDES-PJSIP/iOS-2.14.1-libs

cd ../iOS-2.14.1-libs

ls *.a|awk -F "64" '{print "mv "$0" "$1$2""}'|bash
