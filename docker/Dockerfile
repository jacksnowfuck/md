# 构建阶段
FROM docker-0.unsee.tech/node:20-alpine as builder
WORKDIR /app

# 设置淘宝镜像源和环境变量
RUN npm config set registry https://registry.npmmirror.com
ENV NODE_ENV=production

# 复制 package.json 并修改
COPY package*.json ./
RUN sed -i 's/"postinstall": ".*"/"postinstall": ""/' package.json && \
    sed -i 's/"prepare": ".*"/"prepare": ""/' package.json

# 安装依赖
RUN npm install --legacy-peer-deps --production=false

# 复制源代码
COPY . .

# 构建静态文件
RUN npm run build

# 使用 nginx 托管静态文件
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"] 