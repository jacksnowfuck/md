# 构建阶段
FROM docker-0.unsee.tech/node:20-alpine
WORKDIR /app

# 设置淘宝镜像源
RUN npm config set registry https://registry.npmmirror.com

# 安装依赖
COPY package*.json ./
RUN npm install --legacy-peer-deps

# 复制源代码
COPY . .

# 删除 simple-git-hooks 相关命令
RUN if [ -f "package.json" ]; then \
    sed -i 's/"prepare": ".*"/"prepare": ""/' package.json; \
    fi

# 构建
RUN npm run build

# 安装 serve
RUN npm install -g serve

# 暴露端口
EXPOSE 3000

# 启动服务
CMD ["serve", "-s", "dist", "-l", "3000"]