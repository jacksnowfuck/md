# 构建阶段
FROM node:20-alpine
WORKDIR /app

# 安装依赖
COPY package*.json ./
RUN npm install

# 复制源代码
COPY . .

# 构建
RUN npm run build

# 安装生产环境依赖
RUN npm install -g serve

# 暴露端口
EXPOSE 3000

# 启动服务
CMD ["serve", "-s", "dist", "-l", "3000"] 