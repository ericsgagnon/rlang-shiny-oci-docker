# rlang-shiny-oci-docker
Multi-stage docker build to extend rocker/shiny-verse with oracle oci.

1. Oracle Instant Client: using oracle linux to install instant client per

    https://github.com/oracle/docker-images/blob/master/OracleInstantClient

2.  R Shiny: copy OIC (with OCI) from previous stage into rocker/shiny-verse image
