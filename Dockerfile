FROM mono
ADD . /src
WORKDIR /src
RUN apt-get update

# Installing Xamarin.Android
RUN tar xjf ./xamarin.android-oss_v9.2.99.71_Linux-x86_64_master_3eb9c78c-Release.tar.bz2
RUN mkdir /usr/lib/mono/xbuild/Xamarin/
RUN cp -a xamarin.android-oss_v9.2.99.71_Linux-x86_64_master_3eb9c78c-Release/bin/Release/lib/xamarin.android/xbuild/Xamarin/. /usr/lib/mono/xbuild/Xamarin/
RUN cp -a xamarin.android-oss_v9.2.99.71_Linux-x86_64_master_3eb9c78c-Release/bin/Release/lib/xamarin.android/xbuild-frameworks/. /usr/lib/mono/xbuild-frameworks/
RUN rm -rf xamarin.android-oss_v9.2.99.71_Linux-x86_64_master_3eb9c78c-Release/
RUN rm xamarin.android-oss_v9.2.99.71_Linux-x86_64_master_3eb9c78c-Release.tar.bz2
RUN du -h /usr/lib/mono/xbuild
RUN du -h /usr/lib/mono/xbuild-frameworks

# Installing openjdk 8
RUN apt-get install -y software-properties-common
RUN apt-get install -y gnupg
RUN add-apt-repository -y ppa:webupd8team/java
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update --yes
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN mkdir -p /usr/share/man/man1
RUN apt-get install --yes oracle-java8-installer
RUN java -version

# Installing Android SDK
RUN apt-get install unzip
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools-linux-4333796.zip -d sdk-tools-linux-4333796
RUN mkdir /usr/lib/android-sdk
RUN cp -a sdk-tools-linux-4333796/. /usr/lib/android-sdk
RUN rm -rf sdk-tools-linux-4333796/
RUN rm sdk-tools-linux-4333796.zip
RUN ls /usr/lib/android-sdk

# Set environment variable
ENV ANDROID_HOME /usr/lib/android-sdk
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

# Make license agreement
RUN mkdir $ANDROID_HOME/licenses && \
    echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license && \
    echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license && \
    echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> $ANDROID_HOME/licenses/android-sdk-license && \
    echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license
RUN cd $ANDROID_HOME && \
    tools/bin/sdkmanager "build-tools;28.0.3" "ndk-bundle" "patcher;v4" "platform-tools" && \
    tools/bin/sdkmanager "platforms;android-28" "add-ons;addon-google_apis-google-24" && \
    tools/bin/sdkmanager "extras;google;google_play_services" "extras;android;m2repository" "extras;google;m2repository"
RUN ls /usr/lib/android-sdk
RUN du -h /usr/lib/android-sdk

