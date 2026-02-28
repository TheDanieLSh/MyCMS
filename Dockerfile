# Базовый образ для рантайма
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
# original template exposed 5000/5001; our development profile uses 8080
EXPOSE 8080

# Полный SDK + исходники + горячая перезагрузка
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS development
WORKDIR /src

# Копируем все исходники
COPY . .
RUN dotnet restore "MyCMS.csproj"

# Устанавливаем EF Tools глобально
RUN dotnet tool install --global dotnet-ef --version 10.0.3
ENV PATH="$PATH:${PATH}:/root/.dotnet/tools"

# Горячая перезагрузка (hot reload)
# these ports are redundant with the base image but we keep them for clarity
EXPOSE 8080

# Финальный образ разработки
FROM development AS final
WORKDIR /src

# when running inside the container we don't need the Visual Studio "Docker" launch
# profile.  dotnet-watch doesn't understand that type and will try to launch a
# browser using the strange URL you saw earlier.  Instead we expose the ports and
# let Kestrel listen on all network interfaces.

# listen only on HTTP; HTTPS requires a certificate (not present in the
# container), which otherwise causes the "Unable to configure HTTPS endpoint"
# error you saw.  Add cert support if/when you need secure traffic.
ENV ASPNETCORE_URLS="http://+:8080"

ENTRYPOINT ["dotnet", "watch", "--project", "MyCMS.csproj", "run", "--launch-profile", "Container (Dockerfile)"]
