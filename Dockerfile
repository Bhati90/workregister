# Dockerfile

# Use an official Python runtime as a parent image
FROM python:3.13-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies needed for GDAL
RUN apt-get update && apt-get install -y \
    libgdal-dev

# Copy the requirements file into the container
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Expose the port Gunicorn will run on
EXPOSE 8000

# Set the command to run your app with Gunicorn
CMD ["gunicorn", "labour_crm.wsgi", "--bind", "0.0.0.0:8000"]
