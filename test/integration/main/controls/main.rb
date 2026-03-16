title "Main Resources"

src_project_id = input("src_project_id")
dst_project_id = input("dst_project_id")
src_region = input("src_region")
dst_region = input("dst_region")
src_router_name = input("src_router_name")
dst_router_name = input("dst_router_name")
src_gateway_name = input("src_gateway_name")
dst_gateway_name = input("dst_gateway_name")
src_tunnel_names = input("src_tunnel_names")
dst_tunnel_names = input("dst_tunnel_names")

control "gcp-vpn-source-1.0" do
  impact 1.0
  title "Ensure source VPN resources exist"

  describe google_compute_router(project: src_project_id, region: src_region, name: src_router_name) do
    it { should exist }
  end

  describe google_compute_vpn_gateways(project: src_project_id, region: src_region) do
    it { should exist }
    its("names") { should include src_gateway_name }
  end

  src_tunnel_names.each do |tunnel_name|
    describe google_compute_vpn_tunnel(project: src_project_id, region: src_region, name: tunnel_name) do
      it { should exist }
    end
  end
end

control "gcp-vpn-destination-1.0" do
  impact 1.0
  title "Ensure destination VPN resources exist"

  describe google_compute_router(project: dst_project_id, region: dst_region, name: dst_router_name) do
    it { should exist }
  end

  describe google_compute_vpn_gateways(project: dst_project_id, region: dst_region) do
    it { should exist }
    its("names") { should include dst_gateway_name }
  end

  dst_tunnel_names.each do |tunnel_name|
    describe google_compute_vpn_tunnel(project: dst_project_id, region: dst_region, name: tunnel_name) do
      it { should exist }
    end
  end
end
