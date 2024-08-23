
# Overview
Federation demo using Datashield via Opal.   Keycloak is configured here for alterate OICD, though this is **not currently** finished for demo purposes.

# Pre-reqs
- A working docker setup

# Step 1. Run the 2-site Opal server setup in *datashield/* .
(note: may be docker-compose or docker compose ...)
```bash
cd datashield
docker-compose -f docker-compose-site1.yml -f docker-compose-site2.yml up
```



