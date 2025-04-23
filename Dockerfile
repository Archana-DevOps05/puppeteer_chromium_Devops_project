# Stage 1: Node.js Scraper with Puppeteer & Chromium
FROM node:22-alpine AS scraper

# Puppeteer/Chromium dependencies for Alpine
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    nodejs \
    yarn

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

COPY package.json .
RUN npm install

COPY scrape.js .

# Accept URL as build ARG and ENV
ARG SCRAPE_URL
ENV SCRAPE_URL=$SCRAPE_URL

# Run scraper
RUN node scrape.js

# Stage 2: Python Flask App
FROM python:3.10-alpine AS server

WORKDIR /app

COPY --from=scraper /app/scraped_data.json .
COPY server.py .
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000
CMD ["python", "server.py"]
