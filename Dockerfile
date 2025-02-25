# 构建阶段
FROM docker-0.unsee.tech/node:20-alpine
WORKDIR /app

# 设置淘宝镜像源和环境变量
RUN npm config set registry https://registry.npmmirror.com
ENV NODE_ENV=production

# 复制 package.json 并修改
COPY package*.json ./
RUN sed -i 's/"postinstall": ".*"/"postinstall": ""/' package.json && \
    sed -i 's/"prepare": ".*"/"prepare": ""/' package.json

# 安装依赖（只安装生产依赖）
RUN npm install --legacy-peer-deps --production=false

# 复制源代码
COPY . .

# 构建
RUN NODE_ENV=production npm run build

# 安装 serve
RUN npm install -g serve

# 暴露端口
EXPOSE 3000

# 启动服务
CMD ["serve", "-s", "dist", "-l", "3000"]