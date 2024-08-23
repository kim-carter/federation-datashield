
## Overview
Federation demo using Datashield via Opal.   Keycloak is configured here for alterate OICD, though this is **not currently** finished for demo purposes.

## Pre-reqs
- A working docker setup

### Step 1. Run the 2-site Opal server setup in *datashield/* .
(note: may be docker-compose or docker compose ...)
```bash
cd datashield
docker-compose -f docker-compose-site1.yml -f docker-compose-site2.yml up
```

All going well, Opal with Rservers should be running in your terminal (or daemonised with -d).  You can check by hitting https://localhost:8844 and https://localhost:8845 in your broweser.

### Step 2. Build the Dockerised R datashield container

```bash
cd R
docker build -t rdocker:latest .
```

When complete, this R rdocker image will have all of the packages necessary for client or server-side datashield analysis

### Step 3. Make sample data authorised for federation from the server side
```bash
docker run -network="host" -it rdocker:latest R
```

Run the command above to open an R console in a separate terminal window.   Paste in the code from [R/SetupServers.R](R/SetupServers.R) line by line or block.

### Step 4. Run the Client code to test
```
To run this on linux with GUI without having to mess with xhost:
```bash
XAUTHORITY=$(xauth info | grep "Authority file" | awk '{ print $3 }'); docker run -it  --network="host" --env DISPLAY=$DISPLAY -v $XAUTHORITY:/root/.Xauthority:ro  rdocker:latest R 
```
Or just:
```bash
# docker run -network="host" -it rdocker:latest R
```

Run the command above to open an R console in a separate terminal window.   Paste in the code from [R/ClientQuery.R](R/ClientQuery.R) line by line or block.

