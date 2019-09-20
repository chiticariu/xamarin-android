FROM fedora:27
MAINTAINER Claudiu Chiticariu Constatin <chiticariu@gmail.com>

RUN dnf install gnupg wget dnf-plugins-core -y  \
	&& rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" \
	&& dnf config-manager --add-repo http://download.mono-project.com/repo/centos7/ \
        && dnf install libzip bzip2 bzip2-libs mono-devel nuget msbuild referenceassemblies-pcl lynx -y \
        && dnf clean all

RUN dnf install curl unzip java-1.8.0-openjdk-headless java-1.8.0-openjdk-devel -y && \
    dnf clean all
    
RUN mkdir -p /android/sdk && \
    curl -k https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -o sdk-tools-linux-3859397.zip && \
    unzip -q sdk-tools-linux-3859397.zip -d /android/sdk && \
    rm sdk-tools-linux-3859397.zip

RUN cd /android/sdk && \
    yes | ./tools/bin/sdkmanager --licenses && \
    ./tools/bin/sdkmanager 'build-tools;27.0.3' 'build-tools;28.0.3' platform-tools 'platforms;android-28' 'platforms;android-27' 'platforms;android-26' 'ndk-bundle'

RUN lynx -listonly -dump https://jenkins.mono-project.com/view/Xamarin.Android/job/xamarin-android-linux/lastSuccessfulBuild/Azure/ | grep -o "https://.*/Azure/processDownloadRequest/xamarin-android/xamarin.android-oss_v.*-Release.tar.bz2" > link.txt && \
    curl -L $(cat link.txt) \
        -o xamarin.tar.bz2 && \
    bzip2 -cd xamarin.tar.bz2 | tar -xvf - && \
    mv xamarin.android-oss_v* /android/xamarin && \
    ln -s /android/xamarin/bin/Release/lib/xamarin.android/xbuild/Xamarin /usr/lib/mono/xbuild/Xamarin && \
    ln -s /android/xamarin/bin/Release/lib/xamarin.android/xbuild-frameworks/MonoAndroid/ /usr/lib/mono/xbuild-frameworks/MonoAndroid && \
    ln -s /usr/lib64/libzip.so.5 /usr/lib64/libzip.so.4 && \
    rm xamarin.tar.bz2
    
ENV ANDROID_NDK_PATH=/android/sdk/ndk-bundle
ENV ANDROID_HOME=/android/sdk/
ENV PATH=/android/xamarin/bin/Debug/bin:$PATH
ENV JAVA_HOME=/usr/lib/jvm/java/