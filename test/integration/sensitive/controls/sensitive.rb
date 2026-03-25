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
