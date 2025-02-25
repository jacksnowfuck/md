# 构建阶段
FROM docker-0.unsee.tech/node:20-alpine
WORKDIR /app

# 设置淘宝镜像源
RUN npm config set registry https://registry.npmmirror.com

# 复制 package.json 并修改
COPY package*.json ./
RUN sed -i 's/"postinstall": ".*"/"postinstall": ""/' package.json && \
    sed -i 's/"prepare": ".*"/"prepare": ""/' package.json

# 安装依赖
RUN npm install --legacy-peer-deps

# 复制源代码
COPY . .

# 构建 (添加 --debug 参数和更长的超时时间)
RUN npm run build --debug || (echo "Build failed with error $?" && exit 1)

# 安装 serve
RUN npm install -g serve

# 暴露端口
EXPOSE 3000

# 启动服务
CMD ["serve", "-s", "dist", "-l", "3000"]