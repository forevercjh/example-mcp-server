#!/bin/sh

# 启动服务
exec uvicorn server:app \
    --host 0.0.0.0 \
    --port $PORT \
    --workers $WORKERS \
    --proxy-headers \
    --no-server-header