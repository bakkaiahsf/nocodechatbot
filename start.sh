#!/bin/bash

# Check if models exist, train if not
MODEL_COUNT=$(find /app/models -name "*.tar.gz" | wc -l)
if [ "$MODEL_COUNT" -eq 0 ]; then
  echo "No models found, training new model..."
  rasa train || echo "Training failed, but continuing startup"
fi

# Start the actions server in the background
rasa run actions --port 5055 &

# Wait for actions server to start
sleep 10

# Start the main Rasa server on port 8000 (in foreground) WITH REST CHANNEL
rasa run --enable-api --cors "*" --connector rest --port 8000
rasa run --enable-api --cors "*" --port 8000 --endpoints endpoints.yml --connector rest