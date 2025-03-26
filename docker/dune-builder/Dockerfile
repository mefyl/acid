FROM alpine:3.20.3 AS opam-base

RUN apk add --no-cache bash curl docker-cli docker-cli-buildx gcc g++ git make npm patch s3fs-fuse tzdata

# Ensuring reproducibility, the poor man's way.
RUN curl -fsSL https://get.dune.build/install | sed 's#dune_tar_uri=.*#dune_tar_uri="https://get.dune.build/2025-03-26/x86_64-unknown-linux-musl/dune-2025-03-26-x86_64-unknown-linux-musl.tar.gz"#' | sh
ADD dune-config /root/.config/dune/config
ENV PATH="/root/.local/bin:$PATH"
RUN sh -c 'test $(dune --version | tail -n 1) = 5251af8477ec1474dfb5fc1272786a8ec30f3030\"'

