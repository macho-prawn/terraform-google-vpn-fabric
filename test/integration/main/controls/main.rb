title "Main Resources"

src_project_id = input("src_project_id")
dst_project_id = input("dst_project_id")
src_region = input("src_region")
dst_region = input("dst_region")
src_router_names = input("src_router_names")
dst_router_names = input("dst_router_names")
src_gateway_names = input("src_gateway_names")
dst_gateway_names = input("dst_gateway_names")
src_tunnel_names = input("src_tunnel_names")
dst_tunnel_names = input("dst_tunnel_names")

control "gcp-vpn-source-1.0" do
  impact 1.0
  title "Ensure source VPN resources exist"

  src_router_names.each do |router_name|
    describe google_compute_router(project: src_project_id, region: src_region, name: router_name) do
      it { should exist }
    end
  end

  describe google_compute_vpn_gateways(project: src_project_id, region: src_region) do
    it { should exist }
    src_gateway_names.each do |gateway_name|
      its("names") { should include gateway_name }
    end
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

  dst_router_names.each do |router_name|
    describe google_compute_router(project: dst_project_id, region: dst_region, name: router_name) do
      it { should exist }
    end
  end

  describe google_compute_vpn_gateways(project: dst_project_id, region: dst_region) do
    it { should exist }
    dst_gateway_names.each do |gateway_name|
      its("names") { should include gateway_name }
    end
  end

  dst_tunnel_names.each do |tunnel_name|
    describe google_compute_vpn_tunnel(project: dst_project_id, region: dst_region, name: tunnel_name) do
      it { should exist }
    end
  end
end
