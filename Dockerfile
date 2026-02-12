# Базовый образ для рантайма
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 5000
EXPOSE 5001

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
EXPOSE 5000
EXPOSE 5001

# Финальный образ разработки
FROM development AS final
WORKDIR /src
ENTRYPOINT ["dotnet", "watch", "--project", "MyCMS.csproj", "run", "--launch-profile", "Container (Dockerfile)"]
