FROM debian:buster
RUN apt-get update
RUN apt-get install -y curl xz-utils
RUN curl -Ls https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-src.tar.xz | tar xvJ -C /usr/src
WORKDIR /usr/src/ghc-8.6.5
RUN printf '%s\n' > mk/build.mk Stage1Only=YES HADDOCK_DOCS=NO WITH_TERMINFO=NO
RUN apt-get install -y gcc-aarch64-linux-gnu c++-aarch64-linux-gnu ghc llvm-6.0-dev make patch m4 bzip2
RUN ./configure --target=aarch64-linux-gnu

# The Haskell ecosystem is not ready for cross-compilation. Here are some hacks.
RUN make -kj $(nproc) || true
RUN mkdir -p /bin/aarch64
RUN cp /usr/bin/aarch64-linux-gnu-ld /bin/aarch64/ld
RUN cp /usr/bin/aarch64-linux-gnu-strip /bin/aarch64/strip
ENV PATH="/bin/aarch64:${PATH}"
RUN make -j $(nproc)
RUN make install
RUN ln -s /usr/src/ghc-8.6.5/inplace/lib /usr/local/lib/aarch64-linux-gnu-ghc-8.6.5/lib
ENV PATH="/usr/local/lib/aarch64-linux-gnu-ghc-8.6.5/bin/:${PATH}"
RUN apt-get install -y cabal-install

# Minimize compilation size
COPY cabal-config /root/.cabal/config

# Pre-install some libraries to speed up builds
RUN cabal update && cabal install \
    Diff-0.3.4 \
    QuickCheck-2.13.2 \
    aeson-1.4.4.0 \
    attoparsec-0.13.2.2 \
    base-compat-0.10.5 \
    base-orphans-0.8.1 \
    dlist-0.8.0.6 \
    hashable-1.3.0.0 \
    integer-logarithms-1.0.3 \
    primitive-0.7.0.0 \
    random-1.1 \
    regex-base-0.93.2 \
    regex-tdfa-1.2.3.2 \
    scientific-0.3.6.2 \
    splitmix-0.0.2 \
    tagged-0.8.6 \
    th-abstraction-0.3.1.0 \
    time-compat-1.9.2.2 \
    unordered-containers-0.2.10.0 \
    uuid-types-1.0.3 \
    vector-0.12.0.3

COPY buildsc /bin
WORKDIR /mnt
