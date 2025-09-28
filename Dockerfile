# Use an official Terraform image (or build from HashiCorp’s base)
FROM hashicorp/terraform:latest

# Set working directory inside the container
WORKDIR /workspace

# Copy all files from the repo into container
COPY . /workspace

# (Optional) If you have Terraform module dependencies, download them
RUN terraform init -input=false

# (Optional) To validate or plan, you could add:
# RUN terraform validate
# RUN terraform plan -out=tfplan

# By default, open up a shell (you can override CMD in docker run)
CMD ["sh"]
