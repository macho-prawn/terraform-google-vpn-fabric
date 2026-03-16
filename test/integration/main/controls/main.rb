title "Main Resources"

###################################################################################
#
# Write test cases here
#
###################################################################################

# Below is the test case to check if a bucket is present in the correct location

=begin
# load the inputs (output by Terraform, stored in inputs.yaml by the pipeline)
bucket_name = input("bucket_name")

control "gcp-bucket-1.0" do                             # A unique ID for this control
  impact 1.0                                            # The criticality, if this control fails.
  title "Ensure bucket is correct"                      # A human-readable title

  describe google_storage_bucket(name: bucket_name) do
    it { should exist }
    its('location') { should cmp 'US' }
    its('storage_class') { should eq "STANDARD" }
    
    # Not supported by inspec-gcp :(
    #its('uniform_bucket_level_access') { should eq true }
    
    # doesn't work because this is a Terraform meta directive, not a Google concept?
    #its('force_destroy') { should eq true }
  end

  describe google_storage_bucket(name: "nonexistent") do
    it { should_not exist }
  end

end
=end