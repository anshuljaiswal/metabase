###################
# STAGE 1: builder
###################

FROM metabase/ci:java-11-clj-1.11.0.1100.04-2022-build as builder

ARG MB_EDITION=oss

WORKDIR /home/circleci

COPY --chown=circleci . .
RUN INTERACTIVE=false CI=true MB_EDITION=$MB_EDITION bin/build

# ###################
# # STAGE 2: runner
# ###################

## Remember that this runner image needs to be the same as bin/docker/Dockerfile with the exception that this one grabs the
## jar from the previous stage rather than the local build
## we're not yet there to provide an ARM runner till https://github.com/adoptium/adoptium/issues/96 is ready

FROM --platform=$TARGETPLATFORM eclipse-temurin:11-jre-focal
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG BUILDARCH
ARG TARGETARCH

ENV FC_LANG en-US LC_CTYPE en_US.UTF-8

# dependencies
RUN apt-get update -yq && apt-get install -yq bash ttf-dejavu fontconfig curl openjdk-11-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    mkdir -p /app/certs && \
    curl https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem -o /app/certs/rds-combined-ca-bundle.pem  && \
    /opt/java/openjdk/bin/keytool -noprompt -import -trustcacerts -alias aws-rds -file /app/certs/rds-combined-ca-bundle.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit && \
    curl https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem -o /app/certs/DigiCertGlobalRootG2.crt.pem  && \
    /opt/java/openjdk/bin/keytool -noprompt -import -trustcacerts -alias azure-cert -file /app/certs/DigiCertGlobalRootG2.crt.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit && \
    mkdir -p /plugins && chmod a+rwx /plugins && \
    useradd --shell /bin/bash metabase

USER metabase
WORKDIR /app

# copy app from the offical image
COPY --from=builder /home/circleci/target/uberjar/metabase.jar /app/
COPY bin/docker/run_metabase.sh /app/

# expose our default runtime port
EXPOSE 3000

# run it
ENTRYPOINT ["/app/run_metabase.sh"]
