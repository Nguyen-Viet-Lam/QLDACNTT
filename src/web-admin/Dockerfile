# ========================================================
# Dockerfile cho Web Admin Dashboard (TechCare Repair Shop)
# Sinh vien: Nguyen Viet Lam (PM / DevOps) - Nhom 11 - 23DTHC6
# ========================================================

FROM nginx:alpine

# Copy cấu hình Nginx Reverse Proxy
COPY src/web-admin/nginx.conf /etc/nginx/conf.d/default.conf

# Copy giao diện tĩnh SPA vào thư mục gốc của Nginx
COPY src/web-admin/index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
