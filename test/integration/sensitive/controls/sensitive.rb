title "Sensitive Resources"

# load the inputs (output by Terraform, stored in inputs.yaml by the pipeline)
src_project_id = input("src_host_project_id")
dst_project_id = input("dst_host_project_id")
secret_project_id = input("secret_project_id")

control "gcp-projects-1.0" do
  impact 1.0
  title "Ensure source, destination, and secret projects exist"

  describe google_project(project: src_project_id) do
    it { should exist }
  end

  describe google_project(project: dst_project_id) do
    it { should exist }
  end

  describe google_project(project: secret_project_id) do
    it { should exist }
  end
end

control "gcp-secrets-1.0" do
  impact 1.0
  title "Ensure the secret project contains the expected VPN secrets"

  describe google_secret_manager_secrets(parent: "projects/#{secret_project_id}") do
    it { should exist }
    its("secret_ids") { should include "vpn_preshared_key_project" }
    its("secret_ids") { should include "vpn_preshared_key_tunnel" }
  end
end
