# # FROM ankane/pgvector
# FROM pgvector/pgvector:pg17

# # # Installer les dépendances et pgvector
# RUN apt update && apt update \
#     && apt install postgresql-17-pgvector

# # ENV LANG=en_US.UTF-8
# # ENV LANGUAGE=en_US:en
# # ENV LC_ALL=en_US.UTF-8


FROM postgres:17

# Installer le paquet officiel pgvector
RUN apt-get update && apt-get install -y \
    postgresql-17-pgvector \
    && rm -rf /var/lib/apt/lists/*
