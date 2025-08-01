# Use official Python image
FROM python:3.12-slim

# Set work directory
WORKDIR /app

# Install GDAL and other system dependencies.
# Added libpq-dev for the psycopg2 dependency.
RUN apt-get update && apt-get install -y \
    gdal-bin \
    libgdal-dev \
    libpq-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Environment variable for GDAL
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

# Copy and install Python dependencies
# This is a key step. We copy requirements.txt first to leverage Docker's cache.
# If requirements.txt doesn't change, this layer is cached and doesn't run again.
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project files
COPY . /app/

# Collect static files
# This command is executed in a new layer, after all dependencies are installed.
# If Django is successfully installed above, this will now work.
RUN python manage.py collectstatic --noinput

# Expose the port
EXPOSE 8000

# Run Django with Gunicorn
# This is the command that Render will use to start your application.
CMD python manage.py migrate && gunicorn labour_crm.wsgi:application --bind 0.0.0.0:8000