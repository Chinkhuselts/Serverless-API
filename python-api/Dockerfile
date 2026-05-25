# We use Oracle's official Serverless Python image
FROM fnproject/python:3.11

WORKDIR /function

# Install the FDK requirements
COPY requirements.txt .
RUN pip install --target /python/ --no-cache-dir -r requirements.txt

# Copy our actual API logic
COPY func.py .

# Tell the container how to run the serverless function
ENV PYTHONPATH=/python
ENTRYPOINT ["/python/bin/fdk", "/function/func.py", "handler"]
