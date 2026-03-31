title "Main Resources"

src_projects = input("src_projects")
dst_projects = input("dst_projects")

control "gcp-vpn-source-1.0" do
  impact 1.0
  title "Ensure source VPN resources exist"

  src_projects.each do |src_project_id, src_regions|
    src_regions.each do |src_region, src_resources|
      src_router_names = src_resources.fetch("router_names")
      src_gateway_names = src_resources.fetch("gateway_names")
      src_tunnel_names = src_resources.fetch("tunnel_names")

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
  end
end

control "gcp-vpn-destination-1.0" do
  impact 1.0
  title "Ensure destination VPN resources exist"

  dst_projects.each do |dst_project_id, dst_regions|
    dst_regions.each do |dst_region, dst_resources|
      dst_router_names = dst_resources.fetch("router_names")
      dst_gateway_names = dst_resources.fetch("gateway_names")
      dst_tunnel_names = dst_resources.fetch("tunnel_names")

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
  end
end
