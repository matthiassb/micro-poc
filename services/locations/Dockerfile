FROM public.ecr.aws/lambda/ruby:2.7

COPY app.rb Gemfile ${LAMBDA_TASK_ROOT}

RUN bundle install

CMD [ "app.handler" ]
