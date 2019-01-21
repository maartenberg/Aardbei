source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'

# Use Puma as the app server
gem 'puma', '~> 3.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets, babel for ES6
gem 'babel-transpiler'
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Bootstrap for CSS
gem 'autoprefixer-rails'
gem 'bootstrap-sass', '~> 3.3.6'

# In-place editing
gem 'x-editable-rails'

# Fake data generation
gem 'faker'

# Use HAML for templates
gem 'haml'

# Use RABL for JSON
gem 'oj'
gem 'rabl'

# Clipping
gem 'clipboard-rails'

# Use Fontawesome icons
gem 'font-awesome-sass'

# Use YARD for documentation
gem 'yard'

# Use Mailgun for mail
gem 'mailgun_rails'

# Pagination
gem 'will_paginate', '~> 3.1.0'

# Bootstrap integration for will_paginate
gem 'bootstrap-will_paginate'

# Delayed jobs
gem 'daemons'
gem 'delayed_job'
gem 'delayed_job_active_record'

# Error reporting
gem 'sentry-raven'

# Calendar support
gem 'icalendar'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Use sqlite3 as the database for development
  gem 'sqlite3'

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  gem 'web-console'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Translation helpers
  gem 'i18n_generators'

  # Codestyle enforcement
  gem 'rubocop'
end

group :production do
  # Use a real database in production
  gem 'pg'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
