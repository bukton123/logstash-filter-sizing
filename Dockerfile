FROM docker.elastic.co/logstash/logstash:8.6.2

USER root

COPY logstash-filter-sizing-1.0.0.gem  /
COPY logstash-filter-event-1.0.0.gem  /
RUN logstash-plugin install /logstash-filter-sizing-1.0.0.gem 
RUN logstash-plugin install /logstash-filter-event-1.0.0.gem 