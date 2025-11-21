# Guía de Instalación - Buscador FP Dual

## 🚀 Instalación Rápida (Recomendado)

La forma más rápida es usar el script de instalación automática. Este configura todo en una sola ejecución:

```bash
sudo bash install.sh
```

**¿Qué hace el script?**
- Actualiza el sistema
- Instala Node.js 20.x
- Instala PostgreSQL
- Crea base de datos y usuario
- Clona el repositorio
- Instala dependencias npm
- Configura Nginx como reverse proxy
- Crea servicio systemd
- Compila la aplicación
- Inicia el servicio

## ⚙️ Configuración Post-Instalación

### 1. Acceder a la Aplicación

Después de la instalación, la aplicación estará disponible en:

```
http://your-server-ip
```

O si tienes un dominio:

```
https://tu-dominio.com
```

### 2. SSL/HTTPS (Let's Encrypt)

Para usar HTTPS con un certificado gratuito:

```bash
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot --nginx -d tu-dominio.com
```

Nginx se actualizará automáticamente para usar HTTPS.

### 3. Firewall

Si usas ufw:

```bash
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw enable
```

### 4. Monitoreo y Logs

Ver estado del servicio:

```bash
sudo systemctl status buscador-fp-dual
```

Ver logs en tiempo real:

```bash
sudo tail -f /var/log/buscador-fp-dual/app.log
```

Ver errores:

```bash
sudo tail -f /var/log/buscador-fp-dual/error.log
```

### 5. Backup de Base de Datos

Crear backup:

```bash
sudo -u postgres pg_dump buscador_fp_dual > backup.sql
```

Restaurar backup:

```bash
sudo -u postgres psql buscador_fp_dual < backup.sql
```

## 📋 Instalación Manual Paso a Paso

Si prefieres hacer la instalación manualmente:

### Paso 1: Preparar el Sistema

```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y curl wget git build-essential
```

### Paso 2: Instalar Node.js

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version  # Verificar instalación
```

### Paso 3: Instalar PostgreSQL

```bash
sudo apt-get install -y postgresql postgresql-contrib libpq-dev
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Paso 4: Crear Base de Datos

```bash
sudo -u postgres psql
```

En el prompt de psql, ejecuta:

```sql
-- Crear extensión UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear base de datos
CREATE DATABASE buscador_fp_dual 
  ENCODING 'UTF8' 
  LC_COLLATE 'en_US.UTF-8' 
  LC_CTYPE 'en_US.UTF-8';

-- Crear usuario
CREATE USER buscador_user WITH PASSWORD 'tu_contraseña_muy_segura_aqui';

-- Configurar usuario
ALTER ROLE buscador_user SET client_encoding TO 'utf8';
ALTER ROLE buscador_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE buscador_user SET default_transaction_deferrable TO on;
ALTER ROLE buscador_user SET timezone TO 'UTC';

-- Otorgar permisos
GRANT ALL PRIVILEGES ON DATABASE buscador_fp_dual TO buscador_user;
ALTER DATABASE buscador_fp_dual OWNER TO buscador_user;

-- Salir
\q
```

### Paso 5: Crear Usuario de Sistema

```bash
sudo useradd -r -s /bin/bash -d /opt/buscador-fp-dual -m buscador
```

### Paso 6: Clonar Repositorio

```bash
sudo -u buscador git clone https://github.com/innovafpiesmmg/buscador-fp-dual.git /opt/buscador-fp-dual
cd /opt/buscador-fp-dual
```

### Paso 7: Configurar Variables de Entorno

```bash
cp .env.example .env
sudo nano .env
```

Edita con tus valores:

```
DATABASE_URL=postgresql://buscador_user:tu_contraseña@localhost:5432/buscador_fp_dual
PGUSER=buscador_user
PGPASSWORD=tu_contraseña
PGDATABASE=buscador_fp_dual
PGHOST=localhost
PGPORT=5432
NODE_ENV=production
PORT=5000
```

### Paso 8: Instalar Dependencias y Migrar BD

```bash
sudo -u buscador npm install
sudo -u buscador npm run db:push
```

### Paso 9: Compilar Aplicación

```bash
sudo -u buscador npm run build
```

### Paso 10: Crear Servicio Systemd

```bash
sudo cat > /etc/systemd/system/buscador-fp-dual.service << 'EOF'
[Unit]
Description=Buscador FP Dual - Islas Canarias
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=buscador
WorkingDirectory=/opt/buscador-fp-dual
Environment="NODE_ENV=production"
EnvironmentFile=/etc/buscador-fp-dual.conf
ExecStart=/usr/bin/npm run start
Restart=on-failure
RestartSec=10
StandardOutput=append:/var/log/buscador-fp-dual/app.log
StandardError=append:/var/log/buscador-fp-dual/error.log

[Install]
WantedBy=multi-user.target
EOF

sudo mkdir -p /var/log/buscador-fp-dual
sudo chown buscador:buscador /var/log/buscador-fp-dual
sudo systemctl daemon-reload
sudo systemctl enable buscador-fp-dual.service
```

### Paso 11: Configurar Nginx

```bash
sudo apt-get install -y nginx

sudo cat > /etc/nginx/sites-available/buscador-fp-dual << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /ws {
        proxy_pass http://localhost:5000/ws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/buscador-fp-dual /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### Paso 12: Iniciar Servicio

```bash
sudo systemctl start buscador-fp-dual
sudo systemctl status buscador-fp-dual
```

## ✅ Verificación

Para verificar que todo funciona:

```bash
# Verificar servicio
sudo systemctl status buscador-fp-dual

# Verificar puerto
sudo netstat -tlnp | grep 5000

# Verificar base de datos
psql -U buscador_user -d buscador_fp_dual -c "SELECT version();"

# Acceder a la aplicación
curl http://localhost/
```

## 🐛 Solución de Problemas

### La aplicación no inicia

```bash
# Ver logs detallados
sudo journalctl -u buscador-fp-dual -n 50

# Reiniciar servicio
sudo systemctl restart buscador-fp-dual

# Verificar errores de npm
cd /opt/buscador-fp-dual
npm run build
```

### Error de conexión a BD

```bash
# Verificar que PostgreSQL está corriendo
sudo systemctl status postgresql

# Probar conexión manualmente
psql -U buscador_user -d buscador_fp_dual -h localhost
```

### Chrome/Puppeteer error

```bash
# Instalar Chrome manualmente
npx puppeteer browsers install chrome
```

### Permisos insuficientes

```bash
sudo chown -R buscador:buscador /opt/buscador-fp-dual
sudo chown -R buscador:buscador /var/log/buscador-fp-dual
```

## 📱 Actualizaciones

Para actualizar a la última versión:

```bash
cd /opt/buscador-fp-dual
sudo -u buscador git pull origin main
sudo -u buscador npm install
sudo -u buscador npm run build
sudo -u buscador npm run db:push
sudo systemctl restart buscador-fp-dual
```

## 🔐 Seguridad

### Cambiar Contraseña de BD

```bash
sudo -u postgres psql

ALTER USER buscador_user WITH PASSWORD 'nueva_contraseña';
\q
```

Luego actualiza en `/etc/buscador-fp-dual.conf` y `.env`

### Restricción de Acceso

```bash
# Permitir solo desde localhost
sudo ufw default deny incoming
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS
sudo ufw enable
```

---

**¿Necesitas ayuda?** Abre un issue en GitHub: https://github.com/innovafpiesmmg/buscador-fp-dual/issues
