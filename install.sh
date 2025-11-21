#!/bin/bash

###############################################################################
# Buscador FP Dual - Islas Canarias
# Automatic Installation Script for Ubuntu/Debian
# This script automates the complete setup including PostgreSQL, Node.js,
# and application configuration.
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
APP_NAME="Buscador FP Dual - Islas Canarias"
APP_DIR="/opt/buscador-fp-dual"
DB_NAME="buscador_fp_dual"
DB_USER="buscador_user"
APP_USER="buscador"
PORT=5000

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

update_system() {
    log_info "Updating system packages..."
    apt-get update
    apt-get upgrade -y
    log_success "System updated"
}

install_dependencies() {
    log_info "Installing system dependencies..."
    apt-get install -y \
        curl \
        wget \
        git \
        build-essential \
        python3 \
        python3-pip \
        openssl \
        ca-certificates
    log_success "System dependencies installed"
}

install_nodejs() {
    log_info "Installing Node.js 20.x..."
    if command -v node &> /dev/null; then
        log_warning "Node.js already installed: $(node -v)"
        return
    fi
    
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    log_success "Node.js installed: $(node -v)"
}

install_postgresql() {
    log_info "Installing PostgreSQL..."
    if command -v psql &> /dev/null; then
        log_warning "PostgreSQL already installed"
        return
    fi
    
    apt-get install -y \
        postgresql \
        postgresql-contrib \
        libpq-dev
    
    log_success "PostgreSQL installed"
    
    # Start PostgreSQL service
    systemctl start postgresql
    systemctl enable postgresql
    log_success "PostgreSQL service enabled"
}

create_app_user() {
    log_info "Creating application user: $APP_USER..."
    
    if id "$APP_USER" &>/dev/null; then
        log_warning "User $APP_USER already exists"
        return
    fi
    
    useradd -r -s /bin/bash -d "$APP_DIR" -m "$APP_USER"
    log_success "User $APP_USER created"
}

setup_database() {
    log_info "Setting up PostgreSQL database..."
    
    # Generate secure password
    DB_PASSWORD=$(openssl rand -base64 32)
    
    # Create database and user
    sudo -u postgres psql <<EOF
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE DATABASE $DB_NAME ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
ALTER ROLE $DB_USER SET client_encoding TO 'utf8';
ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';
ALTER ROLE $DB_USER SET default_transaction_deferrable TO on;
ALTER ROLE $DB_USER SET default_transaction_level TO 'read committed';
ALTER ROLE $DB_USER SET statement_timeout TO 0;
ALTER ROLE $DB_USER SET lock_timeout TO 0;
ALTER ROLE $DB_USER SET idle_in_transaction_session_timeout TO 0;
ALTER ROLE $DB_USER SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER DATABASE $DB_NAME OWNER TO $DB_USER;
EOF
    
    log_success "PostgreSQL database created"
    
    # Save credentials to secure file
    DB_CONFIG_FILE="/etc/buscador-fp-dual.conf"
    cat > "$DB_CONFIG_FILE" <<EOF
# Buscador FP Dual - Database Configuration
DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
PGUSER="$DB_USER"
PGPASSWORD="$DB_PASSWORD"
PGDATABASE="$DB_NAME"
PGHOST="localhost"
PGPORT="5432"
EOF
    
    chmod 600 "$DB_CONFIG_FILE"
    chown "$APP_USER:$APP_USER" "$DB_CONFIG_FILE"
    
    log_success "Database credentials saved to $DB_CONFIG_FILE"
    echo -e "${YELLOW}Database Password: $DB_PASSWORD${NC}"
}

clone_repository() {
    log_info "Setting up application directory..."
    
    if [ -d "$APP_DIR" ]; then
        log_warning "Application directory already exists"
        read -p "Do you want to pull the latest changes? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$APP_DIR"
            sudo -u "$APP_USER" git pull origin main
        fi
        return
    fi
    
    mkdir -p "$APP_DIR"
    chown "$APP_USER:$APP_USER" "$APP_DIR"
    
    log_info "Cloning repository..."
    # You should replace this with your actual repository URL
    sudo -u "$APP_USER" git clone https://github.com/innovafpiesmmg/buscador-fp-dual.git "$APP_DIR" || {
        log_error "Failed to clone repository. Please clone manually:"
        log_info "git clone https://github.com/innovafpiesmmg/buscador-fp-dual.git $APP_DIR"
        exit 1
    }
    
    log_success "Repository cloned"
}

install_dependencies_npm() {
    log_info "Installing npm dependencies..."
    cd "$APP_DIR"
    
    # Create .env file
    DB_CONFIG_FILE="/etc/buscador-fp-dual.conf"
    if [ -f "$DB_CONFIG_FILE" ]; then
        cp "$DB_CONFIG_FILE" "$APP_DIR/.env"
        chown "$APP_USER:$APP_USER" "$APP_DIR/.env"
        chmod 600 "$APP_DIR/.env"
    else
        log_warning "Database config file not found. Please configure .env manually."
    fi
    
    sudo -u "$APP_USER" npm install
    sudo -u "$APP_USER" npm run db:push
    
    log_success "npm dependencies installed and database migrated"
}

create_systemd_service() {
    log_info "Creating systemd service..."
    
    cat > /etc/systemd/system/buscador-fp-dual.service <<EOF
[Unit]
Description=Buscador FP Dual - Islas Canarias
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=$APP_USER
WorkingDirectory=$APP_DIR
Environment="NODE_ENV=production"
Environment="PORT=$PORT"
EnvironmentFile=-/etc/buscador-fp-dual.conf
ExecStart=/usr/bin/npm run start
Restart=on-failure
RestartSec=10
StandardOutput=append:/var/log/buscador-fp-dual/app.log
StandardError=append:/var/log/buscador-fp-dual/error.log

[Install]
WantedBy=multi-user.target
EOF
    
    # Create log directory
    mkdir -p /var/log/buscador-fp-dual
    chown "$APP_USER:$APP_USER" /var/log/buscador-fp-dual
    
    systemctl daemon-reload
    systemctl enable buscador-fp-dual.service
    
    log_success "Systemd service created"
}

setup_nginx() {
    log_info "Setting up Nginx reverse proxy..."
    
    apt-get install -y nginx
    
    cat > /etc/nginx/sites-available/buscador-fp-dual <<'EOF'
server {
    listen 80;
    server_name _;
    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # WebSocket support
    location /ws {
        proxy_pass http://localhost:5000/ws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 86400;
    }
}
EOF
    
    ln -sf /etc/nginx/sites-available/buscador-fp-dual /etc/nginx/sites-enabled/buscador-fp-dual
    rm -f /etc/nginx/sites-enabled/default
    
    nginx -t && systemctl restart nginx
    systemctl enable nginx
    
    log_success "Nginx configured"
}

build_application() {
    log_info "Building application..."
    cd "$APP_DIR"
    sudo -u "$APP_USER" npm run build
    log_success "Application built"
}

print_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Application Information:${NC}"
    echo "  Name: $APP_NAME"
    echo "  Directory: $APP_DIR"
    echo "  User: $APP_USER"
    echo "  Port: $PORT"
    echo ""
    echo -e "${BLUE}Database Information:${NC}"
    echo "  Database: $DB_NAME"
    echo "  User: $DB_USER"
    echo "  Config: /etc/buscador-fp-dual.conf"
    echo ""
    echo -e "${BLUE}Service Management:${NC}"
    echo "  Start:   sudo systemctl start buscador-fp-dual"
    echo "  Stop:    sudo systemctl stop buscador-fp-dual"
    echo "  Status:  sudo systemctl status buscador-fp-dual"
    echo "  Logs:    sudo tail -f /var/log/buscador-fp-dual/app.log"
    echo ""
    echo -e "${BLUE}Access the application:${NC}"
    echo "  URL: http://$(hostname -I | awk '{print $1}'):$PORT"
    echo ""
}

main() {
    log_info "Starting installation of $APP_NAME..."
    
    check_root
    update_system
    install_dependencies
    install_nodejs
    install_postgresql
    create_app_user
    setup_database
    clone_repository
    install_dependencies_npm
    build_application
    create_systemd_service
    setup_nginx
    print_summary
    
    log_success "Installation complete. Starting service..."
    systemctl start buscador-fp-dual
    sleep 2
    systemctl status buscador-fp-dual
}

# Run main function
main
