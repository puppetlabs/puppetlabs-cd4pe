FROM ruby:2.4.1
RUN apt-get update && \
    apt-get install -y jq && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV SSH_KEY id_rsa
RUN { \
    echo "#!/bin/bash"; \
    echo "eval \$(ssh-agent) >/dev/null"; \
    echo "ssh-add /root/.ssh/\$SSH_KEY"; \
    echo "exec \"\$@\""; \
    } > /entrypoint.sh && chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN mkdir -p /root/.puppetlabs/bolt && \
    echo "disabled: true" > /root/.puppetlabs/bolt/analytics.yaml

COPY .cdpe-workflow-tests-config.json /root/

WORKDIR /app
COPY Gemfile ./
RUN bundle install
WORKDIR /app/test
