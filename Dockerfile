FROM ubuntu:18.04

LABEL       author="Mike Hawke" maintainer="Mike@MikeHawke.co.uk"

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -y \
    && apt upgrade -y \
    && apt install -y lib32gcc1 lib32stdc++6 unzip curl iproute2 libgdiplus \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt install -y nodejs npm \
    && mkdir /node_modules \
    && npm install --prefix / ws \
    && useradd -d /home/container -m container \
    && apt update -y \ 
    && apt install -y wget sudo curl tar zip unzip sed apt-utils ca-certificates \
    && wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt update -y \  
    && apt install -y dotnet-sdk-5.0 aspnetcore-runtime-5.0 libgdiplus

USER container
ENV  USER=container HOME=/home/container
RUN ln -s /home/container/ /nonexistent

RUN dotnet tool update uMod --version "*-*" --global --add-source https://www.myget.org/f/umod/api/v3/index.json
RUN dotnet new -i "uMod.Templates::*-*" --nuget-source https://www.myget.org/f/umod/api/v3/index.json &>/dev/null

RUN export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    && echo "DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1; export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT" >> ~/.profile \
    && export PATH="$PATH:$HOME/.dotnet/tools" \
    && export PATH="$PATH:/home/container/.dotnet/tools" \ 
    && echo "PATH=\$PATH:\$HOME/.dotnet/tools; export PATH" >> ~/.profile \
    && ~/.dotnet/tools/umod complete --install

WORKDIR /home/container

COPY ./wrapper.js /wrapper.js

COPY ./entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]
