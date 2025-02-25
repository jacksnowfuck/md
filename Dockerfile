# 构建阶段
FROM docker-0.unsee.tech/node:20-alpine
WORKDIR /app

# 设置淘宝镜像源和环境变量
RUN npm config set registry https://registry.npmmirror.com

# 复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制项目文件
COPY . .

# 暴露端口（Vite 默认端口是 5173）
EXPOSE 5173

# 运行模拟生产环境的开发服务器
CMD ["npm", "run", "prod:preview"]
