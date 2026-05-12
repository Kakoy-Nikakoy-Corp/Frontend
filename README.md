# WildlifeCV Frontend

## Клонирование и установка зависимостей

```bash
git clone https://github.com/Kakoy-Nikakoy-Corp/WildlifeCV-frontend.git
cd WildlifeCV-frontend
npm install
```

## Запуск SvelteKit в режиме разработки

```bash
npm run dev
```

## Сборка модуля

```bash
npm run build
node build/index.js
```

## Развертывание на сервере при помощи Docker Compose

Добавляем запись в `docker-compose.yaml`:
```yaml
services:
  web:
    build: /<path_to_package>/WildlifeCV-frontend
    container_name: wcv-frontend
    ports:
      - "3000:3000"
    restart: unless-stopped
```

Запускаем контейнеры:
```bash
docker compose up -d
```
