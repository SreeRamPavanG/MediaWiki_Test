Description
-> This project includes files related to provisioning infrastructure and managing configurations using Terraform and Ansible.

Files Overview
-> ansible-plabook.yml: Ansible playbook for configuring servers.
-> backend.tf: Terraform backend configuration for storing state files.
-> file_names.txt: A text file containing the names of files in a directory.
-> hosts: Ansible inventory file listing hosts to be managed.
-> main.tf: Main Terraform configuration file defining infrastructure resources.
-> output.tf: Terraform configuration file for defining output variables.
-> playbook.yml: Ansible playbook for configuring servers.
-> providers.tf: Terraform configuration file for defining provider information.
-> Readme.md: README file providing an overview of the project.
-> terraform.tfvars: Terraform variables file containing variable definitions.
-> vars.tf: Terraform configuration file for defining variables.


Prerequisites :
-> You should have Microsoft Azure account.
-> Download Terraform application into your system and define the path in system environment variables.
-> Download AzureCLI and install in your system.
-> Login by executing this command "az login" in cmd or powershell.


Initialize the Terraform working directory -> terrform init
Generate the execution plan -> terraform plan -out=plan.out
Build the infrastructure using gnerated plan -> terraform apply plan.out
The IP address of the spinned up instance will be printed in the output after successful execution


-> Need to update the Ansible's inventory file, i.e., the hosts file with the output(Spinned up instance's IP address) from terraform execution 
-> ansible-playbook -i hosts playbook.yml --extra-vars="root_password=Root@123 wiki_password=WikiPass123" -u ansible_user --ask-pass
