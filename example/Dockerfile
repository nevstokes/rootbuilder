FROM nevstokes/rootbuilder

COPY ./config /tmp/buildroot/.config

RUN make oldconfig && make --quiet
