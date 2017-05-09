# escape=`
FROM microsoft/dotnet-framework:4.6.2

MAINTAINER dealdiane@netpotential.co.nz

# Versions above 4.6.0 doesn't work with docker
# Issue tracked by: https://github.com/StefanScherer/dockerfiles-windows/issues/9
# Upgrade to latest version when this is fixed: https://github.com/nodejs/node/issues/8897
# ENV NODE_VERSION 4.6.0
# Using the volume workaround (https://github.com/StefanScherer/dockerfiles-windows/tree/master/node-example), nodejs versions > 4.6.0 can be used
ENV NODE_VERSION 6.10.2

# Install .NET Core SDK
RUN powershell -NoProfile -Command $ErrorActionPreference = 'Stop'; `
  Invoke-WebRequest 'https://go.microsoft.com/fwlink/?LinkID=843458' -OutFile C:\dotnet.zip; `
  Expand-Archive C:\dotnet.zip -DestinationPath 'C:\dotnet' -Force; `
  Remove-Item -Force C:\dotnet.zip;
  
RUN setx /M PATH "%PATH%;C:\dotnet"

# Install .NET Framework 4.5.1 SDK
RUN powershell -NoProfile -Command $ErrorActionPreference = 'Stop'; `
  Invoke-WebRequest 'https://download.microsoft.com/download/9/6/0/96075294-6820-4F01-924A-474E0023E407/NDP451-KB2861696-x86-x64-DevPack.exe' -OutFile C:\NDP451-KB2861696-x86-x64-DevPack.exe; `
  Start-Process "C:\NDP451-KB2861696-x86-x64-DevPack.exe" -ArgumentList '/q', '/norestart' -Wait; `
  Remove-Item -Force C:\NDP451-KB2861696-x86-x64-DevPack.exe

# Install .NET Framework 4.6.2 SDK
RUN powershell -NoProfile -Command $ErrorActionPreference = 'Stop'; `
  Invoke-WebRequest 'https://download.microsoft.com/download/E/F/D/EFD52638-B804-4865-BB57-47F4B9C80269/NDP462-DevPack-KB3151934-ENU.exe' -OutFile C:\NDP462-DevPack-KB3151934-ENU.exe; `
  Start-Process "C:\NDP462-DevPack-KB3151934-ENU.exe" -ArgumentList '/q', '/norestart' -Wait; `
  Remove-Item -Force C:\NDP462-DevPack-KB3151934-ENU.exe

# Install node
# From: https://github.com/aspnet/aspnet-docker/blob/master/1.1/nanoserver/sdk/Dockerfile
RUN powershell -Command Invoke-WebRequest https://nodejs.org/dist/v${env:NODE_VERSION}/node-v${env:NODE_VERSION}-win-x64.zip -outfile node.zip; `
    Expand-Archive node.zip -DestinationPath "C:/nodejs-tmp/"; `
    Move-Item "C:/nodejs-tmp/node-v${env:NODE_VERSION}-win-x64" -Destination "C:\nodejs"; `
    Remove-Item -Force "C:/nodejs-tmp/"; `
    Remove-Item -Force node.zip;
    
RUN setx /M PATH "%PATH%;C:\nodejs"

# Install git
RUN powershell -Command Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.12.2.windows.2/MinGit-2.12.2.2-32-bit.zip -OutFile C:\git.zip; `
  Expand-Archive git.zip -DestinationPath "C:/git"; `
  Remove-Item -Force C:/git.zip;
  
RUN setx /M PATH "%PATH%;C:\git\cmd"

# Workaround for https://github.com/nodejs/node/issues/8897
VOLUME C:/app
RUN powershell -NoProfile -Command $ErrorActionPreference = 'Stop'; `
  set-itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices' -Name 'D:' -Value '\??\C:\app' -Type String
WORKDIR 'D:\\'