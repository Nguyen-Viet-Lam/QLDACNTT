# ========================================================
# Dockerfile cho ASP.NET Core 8 Minimal API (TechCare Repair Shop)
# Sinh vien: Nguyen Viet Lam (PM / Backend) - Nhom 11 - 23DTHC6
# ========================================================

# Stage 1: Build môi trường SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy file định nghĩa project và restore dependencies
COPY ["src/backend/QLDACNTT.Api.csproj", "src/backend/"]
RUN dotnet restore "src/backend/QLDACNTT.Api.csproj"

# Copy toàn bộ mã nguồn backend và biên dịch Release
COPY ["src/backend/", "src/backend/"]
WORKDIR "/src/src/backend"
RUN dotnet build "QLDACNTT.Api.csproj" -c Release -o /app/build
RUN dotnet publish "QLDACNTT.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 2: Runtime image tối ưu dung lượng
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Thiết lập biến môi trường chạy trên cổng 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 8080

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "QLDACNTT.Api.dll"]
