#!/bin/bash

###############################################################################
# Database Setup Script
# Standalone script to configure PostgreSQL database for Buscador FP Dual
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

# Configuration
DB_NAME="${1:-buscador_fp_dual}"
DB_USER="${2:-buscador_user}"

log_info "Configuring PostgreSQL Database"
log_info "Database: $DB_NAME"
log_info "User: $DB_USER"

# Generate secure password
DB_PASSWORD=$(openssl rand -base64 32)

# Start PostgreSQL
systemctl start postgresql

# Create database and user
log_info "Creating database and user..."
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

log_success "Database created successfully"

# Create .env file with database credentials
ENV_FILE=".env"
cat > "$ENV_FILE" <<EOF
# Database Configuration
DATABASE_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:5432/$DB_NAME"
PGUSER="$DB_USER"
PGPASSWORD="$DB_PASSWORD"
PGDATABASE="$DB_NAME"
PGHOST="localhost"
PGPORT="5432"

# Application
NODE_ENV="production"
PORT=5000
EOF

log_success ".env file created"
log_info "Database Password: $DB_PASSWORD"
echo ""
echo -e "${YELLOW}Please keep the .env file secure and back it up!${NC}"
