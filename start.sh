#!/bin/bash

BOT_DIR="/sdcard/chat-bot"
REPO_DIR="$HOME/link-bot"
PORT="3003"

echo "🧹 Bersihkan proses lama..."
killall cloudflared 2>/dev/null
killall node 2>/dev/null

echo "🚀 Jalankan bot..."
cd "$BOT_DIR" || exit
node chat.js > bot.log 2>&1 &

sleep 3

echo "🌐 Jalankan cloudflared..."
cloudflared tunnel --url http://localhost:$PORT > cf.log 2>&1 &

echo "⏳ Ambil link tunnel..."
sleep 8

LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cf.log | head -n 1)

if [ -z "$LINK" ]; then
  echo "❌ Link tidak ditemukan!"
  exit 1
fi

echo "✅ Link: $LINK"

echo "$LINK" > "$BOT_DIR/link.txt"

echo "📤 Upload ke GitHub..."
cd "$REPO_DIR" || exit
cp "$BOT_DIR/link.txt" .

git add .
git commit -m "update link"
git push

echo "🎉 Selesai!"
echo "🔗 $LINK"
