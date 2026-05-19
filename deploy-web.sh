#!/bin/bash
set -e

echo "1. Exporting Expo web platform..."
cd "/var/www/html/laravel project/newhrms-mahakali-pack/hrms_mahakali_app"
npx expo export --platform web

echo "2. Syncing assets to /var/www/html/dist..."
rsync -av --delete \
  --exclude='.git*' \
  --exclude='vercel.json' \
  --exclude='.vercelignore' \
  --exclude='deploy-web.sh' \
  --exclude='/node_modules' \
  --exclude='package.json' \
  --exclude='package-lock.json' \
  "./dist/" "/var/www/html/dist"

echo "3. Renaming assets/node_modules to assets/nodemodules..."
if [ -d "/var/www/html/dist/assets/node_modules" ]; then
  rm -rf "/var/www/html/dist/assets/nodemodules"
  mv "/var/www/html/dist/assets/node_modules" "/var/www/html/dist/assets/nodemodules"
fi

echo "4. Replacing references in JS bundles..."
find /var/www/html/dist -name "*.js" -type f -exec sed -i 's/\/assets\/node_modules\//\/assets\/nodemodules\//g' {} +

echo "5. Applying cache-busting timestamp to HTML file script tags..."
TIMESTAMP=$(date +%s)
find /var/www/html/dist -name "*.html" -type f -exec sed -i "s/entry-\([a-f0-9]*\)\.js\(\?v=[0-9]*\)\?/entry-\1.js?v=${TIMESTAMP}/g" {} +

echo "Web deploy compilation completed successfully!"
