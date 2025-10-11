

npx nx build customer-backend --configuration=development --watch &
WEBPACK_PID=$!

echo "Waiting for initial build..."
while [ ! -f /app/dist/backend/customer-backend/main.js ]; do
  sleep 1
done
echo "Initial build complete!"
npx nodemon \
  --watch /app/dist/backend/customer-backend \
  --delay 500ms \
  --verbose \
  /app/dist/backend/customer-backend/main.js
kill $WEBPACK_PID

