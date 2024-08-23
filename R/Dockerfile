FROM rocker/r-ubuntu:22.04
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev libxml2-dev build-essential cmake libssl-dev r-cran-devtools libmariadb-dev libjq-dev libssh-dev libsasl2-dev libjq-dev libpq-dev 
RUN rm -rf /var/lib/apt/lists/*

RUN R -q -e 'install.packages("curl"); install.packages("resourcer", dependencies=TRUE); '
RUN R -q -e 'install.packages("opalr");'

RUN R -q -e 'install.packages(c("dsBaseClient","dsBase","dsOpal"), repos=c(getOption("repos"), "http://cran.datashield.org"), dependencies=TRUE);'
RUN R -q -e 'install.packages("DSOpal");'




