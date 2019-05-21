FROM mono:5.18.1
ADD . /src
WORKDIR /src
RUN apt-get update
RUN mono --version

# Installing Xamarin.Android
RUN mkdir /usr/lib/mono/xbuild/Xamarin/
RUN cp -a xamarin.android-v9.2.99.71/bin/Release/lib/xamarin.android/xbuild/Xamarin/. /usr/lib/mono/xbuild/Xamarin/
RUN cp -a xamarin.android-v9.2.99.71/bin/Release/lib/xamarin.android/xbuild-frameworks/. /usr/lib/mono/xbuild-frameworks/
RUN rm -rf xamarin.android-v9.2.99.71/

# Installing openjdk 8
RUN apt-get install -y software-properties-common gnupg
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
RUN mkdir -p /usr/share/man/man1
RUN apt-get install -y openjdk-8-jdk
RUN java -version

# Installing Android SDK
RUN apt-get install -y unzip wget
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools-linux-4333796.zip -d sdk-tools-linux-4333796
RUN mkdir /usr/lib/android-sdk
RUN cp -a sdk-tools-linux-4333796/. /usr/lib/android-sdk
RUN rm -rf sdk-tools-linux-4333796/
RUN rm sdk-tools-linux-4333796.zip

# Set environment variable
ENV ANDROID_HOME /usr/lib/android-sdk
ENV PATH $ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

# Make license agreement
RUN mkdir $ANDROID_HOME/licenses && \
    echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_HOME/licenses/android-sdk-license && \
    echo d56f5187479451eabf01fb78af6dfcb131a6481e >> $ANDROID_HOME/licenses/android-sdk-license && \
    echo 24333f8a63b6825ea9c5514f83c2829b004d1fee >> $ANDROID_HOME/licenses/android-sdk-license && \
    echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_HOME/licenses/android-sdk-preview-license

# Install Android tools
RUN cd $ANDROID_HOME && \
    tools/bin/sdkmanager "build-tools;28.0.3" "ndk-bundle" "platform-tools" && \
    tools/bin/sdkmanager "platforms;android-28"
