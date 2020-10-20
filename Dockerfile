FROM ubuntu:18.04

ENV TERRAFORM_VERSION=0.13.4

RUN apt-get update && apt-get install jq wget zip -y && \
    #include libc6-compat as a dep https://github.com/pulumi/pulumi/issues/1986
    wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip -o ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin/ && \
    rm ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN apt-get update && apt-get install -y wget software-properties-common && \
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" && \
    apt-get install -y powershell && \
    pwsh -Command "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted" && \
    pwsh -Command "Install-Module -Name Az -AllowClobber -Scope CurrentUser"

RUN apt-get update && apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && apt-get install -y azure-cli

RUN apt-get update && apt-get install -y gnupg2 curl apt-transport-https && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list && \
    apt-get update && \
    yes | ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    yes | ACCEPT_EULA=Y apt-get install -y mssql-tools && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
    ln -s /opt/mssql-tools/bin/* /usr/local/bin/