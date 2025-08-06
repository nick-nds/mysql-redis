# MySQL + Redis Data Layer

Cost-effective RDS and ElastiCache replacement for MVP projects using Docker on EC2.

## What This Is

A containerized data layer (MySQL 8.0 + Redis 7.2) designed to run on a single EC2 instance, replacing managed AWS services to reduce costs during MVP phase. Supports both single-tenant and multi-tenant architectures.

## Quick Start

1. **Launch EC2** (t3.medium minimum)
2. **Clone and configure**
   ```bash
   cp .env.example .env
   # Edit .env with secure passwords
   ```
3. **Deploy**
   ```bash
   docker-compose up -d
   ```

## Database Modes

### Single-Tenant Mode
Use the pre-created `main_app` database:
```sql
-- Your app connects to:
Host: <ec2-ip>
Database: main_app
User: app
Password: <from .env>
```

### Multi-Tenant Mode
Create tenant databases dynamically:
```sql
-- Connect to MySQL as root
docker exec -it mysql-redis-mysql-1 mysql -u root -p

-- Create a tenant database
USE landlord;
CALL create_tenant_database('acme-corp');  -- Creates tenant_acme_corp database

-- Your app manages tenants in the landlord.tenants table
INSERT INTO tenants (tenant_code, database_name) 
VALUES ('acme-corp', 'tenant_acme_corp');

-- View all tenants
SELECT * FROM landlord.tenants;
```

## Multi-Tenant Features

- **Tenant Registry**: `landlord.tenants` table for tracking (managed by your app)
- **Database Creation**: `create_tenant_database` procedure creates `tenant_<code>` database
- **App User Access**: Automatic grant to `app` user for all tenant databases
- **Isolation**: Complete database isolation per tenant
- **Simple Integration**: Call procedure when creating tenant in your application

## Why This Approach

- **Cost**: ~$40/month (EC2) vs ~$100-150/month (RDS + ElastiCache)
- **Simplicity**: Single instance to manage
- **Flexibility**: Supports both single and multi-tenant
- **Migration Path**: Easy to migrate to managed services when scaling

## Production Notes

- Deploy on private subnet
- Configure security groups (ports 3306, 6379)
- Set up EBS snapshots for backups
- Monitor resource usage
- Plan migration to RDS/ElastiCache at scale

## Services

- **MySQL**: Port 3306, single or multi-tenant
- **Redis**: Port 6379, LRU cache with 1GB limit