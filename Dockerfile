# 使用阿里云python3.11镜像
FROM alibaba-cloud-linux-3-registry.cn-hangzhou.cr.aliyuncs.com/alinux3/python:3.11.1
# 设置工作目录
WORKDIR ./nct-mcp-server

# 复制源码
COPY src/ .
# 复制依赖文件并安装
COPY requirements.txt .
COPY config.json .
COPY entrypoint.sh .
RUN pip3 install --upgrade pip -i https://mirrors.aliyun.com/pypi/simple/
RUN pip3 install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ --extra-index-url https://pypi.tuna.tsinghua.edu.cn/simple/

# 设置环境变量
ENV MYSQL_HOST=sitmysql.internal.cn-north-1.mysql.rds.myhuaweicloud.com
ENV MYSQL_PORT=3306
ENV MYSQL_USER=c2_mysql_write
ENV MYSQL_PASSWORD=ShohSahGhecieC8A
ENV MYSQL_DATABASE=metadata
ENV PORT=8080
ENV WORKERS=10

# 启动脚本
RUN chmod +x entrypoint.sh

# 映射端口
EXPOSE $PORT

# 启动命令
CMD ["python3", "server.py"]