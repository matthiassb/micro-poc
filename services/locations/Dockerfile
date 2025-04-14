FROM public.ecr.aws/lambda/ruby:3.4

# Install build dependencies
RUN dnf install -y \
    gcc \
    gcc-c++ \
    make \
    ruby-devel \
    postgresql-devel \
    && dnf clean all

# Set working directory
WORKDIR ${LAMBDA_TASK_ROOT}

# Copy Gemfile first to leverage Docker cache
COPY Gemfile ./

# Install gems with verbose output and ensure they're installed in the correct location
RUN bundle config set --local path 'vendor/bundle' && \
    bundle install --verbose --jobs 4 --retry 3

# Copy the application
COPY . ./

# Verify gems are installed and show their locations
RUN bundle list && \
    ls -la vendor/bundle/ruby/3.4.0/gems/

CMD [ "app.handler" ]
