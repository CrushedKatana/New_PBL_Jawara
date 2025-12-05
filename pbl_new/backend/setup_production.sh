#!/bin/bash
# ============================================
# JAWARA MARKETPLACE - PRODUCTION SETUP (LINUX/MAC)
# ============================================
# Script untuk setup database real production
# 
# Usage: bash setup_production.sh

echo "=== JAWARA MARKETPLACE - SETUP PRODUCTION ==="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database configuration
DB_HOST="localhost"
DB_USER="root"
DB_PASS=""
DB_NAME="marketplace_rtrw"

echo "1️⃣  Creating database..."

# Check if mysql is installed
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL is not installed${NC}"
    exit 1
fi

# Create database
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE $DB_NAME;
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Database created successfully${NC}"
else
    echo -e "${RED}❌ Error creating database${NC}"
    exit 1
fi

echo ""
echo "2️⃣  Running migrations..."

# Run migrations
for migration in migrations/01_auth_users.sql migrations/02_products_categories.sql \
                 migrations/03_chat_messages.sql migrations/04_transactions.sql \
                 migrations/05_ml_detections.sql migrations/06_rt_metrics_activities.sql; do
    
    if [ -f "$migration" ]; then
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$migration"
        echo -e "${GREEN}✅ Executed: $migration${NC}"
    else
        echo -e "${YELLOW}⚠️  Not found: $migration${NC}"
    fi
done

echo ""
echo "3️⃣  Verifying tables..."

tables=("users" "products" "categories" "chat_messages" "transactions" "ml_detections" "rt_metrics_activities")

for table in "${tables[@]}"; do
    count=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -se "SELECT COUNT(*) FROM \`$table\`;" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $table (Records: $count)${NC}"
    else
        echo -e "${RED}❌ $table (Error)${NC}"
    fi
done

echo ""
echo "4️⃣  Seed Users Credentials:"
echo ""
echo "📌 ADMIN"
echo "   Email: admin@jawara.com"
echo "   Password: password123"
echo ""
echo "📌 RT/RW OFFICERS"
echo "   Email: ahmad.rt01@jawara.com | Password: password123"
echo "   Email: budi.rt02@jawara.com | Password: password123"
echo "   Email: candra.rt03@jawara.com | Password: password123"
echo "   Email: dedi.rt04@jawara.com | Password: password123"
echo "   Email: budi.rt05@jawara.com | Password: password123"
echo ""
echo "📌 SAMPLE WARGA"
echo "   Email: lisa@jawara.com | Password: password123"
echo "   Email: dimas@jawara.com | Password: password123"
echo "   Email: sari@jawara.com | Password: password123"
echo "   Email: aminah@jawara.com | Password: password123"
echo ""
echo "=== SETUP COMPLETE ==="
echo -e "${GREEN}✅ Database production ready!${NC}"
echo ""
echo "📝 Next Steps:"
echo "   1. Update Flutter ApiConfig.dart with correct backend URL"
echo "   2. Test login with above credentials"
echo "   3. Verify all features working properly"
