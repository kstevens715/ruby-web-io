FROM ruby:2.4.2

WORKDIR /gem
COPY Gemfile* /gem/
COPY ruby_web_io.gemspec /gem/

RUN cd /tmp
RUN wget --no-verbose https://github.com/Medium/phantomjs/releases/download/v2.1.1/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/
RUN ln -s /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/
RUN phantomjs --version

RUN bundle install
