FROM mongo:latest

RUN apt-get update && apt-get install -y \
    s3cmd

WORKDIR /root/

COPY backup_mongo.sh backup_mongo.sh
RUN chmod +x backup_mongo.sh
CMD /root/backup_mongo.sh
