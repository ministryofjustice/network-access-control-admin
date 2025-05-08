import re
import pandas as pd
from pathlib import Path
from ipaddress import ip_network

# --- USER INPUT SECTION ---
input_folder = Path.home() / 'gitrepos' / 'poc' / 'ATOS CSV conversion'  # Dynamic path for current user


# --- INTERNAL DATA ---
subnet_data = []
reservation_data = []

# Regex patterns
subnet_pattern = re.compile(r"subnet (\d+\.\d+\.\d+\.\d+) netmask (\d+\.\d+\.\d+\.\d+)")
host_line_pattern = re.compile(
    r'^\s*host\s+(\S+)\s*\{.*?hardware ethernet\s+([0-9a-f:]+);.*?fixed-address\s+(\d+\.\d+\.\d+\.\d+);.*?\}\s*#\s*(.*?)\s*(serial\s+\S+)?$',
    re.IGNORECASE | re.MULTILINE
)
router_pattern = re.compile(r"option routers (\d+\.\d+\.\d+\.\d+)")
fits_id_pattern = re.compile(r"#\s*(FITS_\d+)")

# Helper to convert netmask to CIDR
def netmask_to_cidr(ip, netmask):
    return str(ip_network(f"{ip}/{netmask}", strict=False))

# Helper to get usable IPs and exclusion range
def get_usable_ips(cidr_block):
    network = ip_network(cidr_block, strict=False)
    hosts = list(network.hosts())
    first_usable = str(hosts[0])
    mask = network.prefixlen
    if mask == 24:
        exclusion_end = str(hosts[9]) if len(hosts) > 9 else ''
    elif mask == 23:
        exclusion_end = str(hosts[15]) if len(hosts) > 15 else ''
    else:
        exclusion_end = ''
    return str(hosts[0]), str(hosts[-1]), first_usable, exclusion_end

# --- PROCESS FILES ---
for conf_file in input_folder.glob("*.conf"):
    with open(conf_file, "r") as file:
        lines = file.readlines()
        content = ''.join(lines)

    fits_id = None
    cidr_block = None
    router_ip = None

    # Extract FITS ID from line with comment pattern: #FITS_XXXX
    for line in lines:
        match = fits_id_pattern.search(line)
        if match:
            fits_id = match.group(1)
            break

    # Find Subnet CIDR
    subnet_match = subnet_pattern.search(content)
    if subnet_match:
        subnet_ip, netmask = subnet_match.groups()
        cidr_block = netmask_to_cidr(subnet_ip, netmask)

    # Find Router IP
    router_match = router_pattern.search(content)
    if router_match:
        router_ip = router_match.group(1)

    # Calculate Start and End IPs, exclusion range
    start_ip, end_ip, exclusion_start, exclusion_end = ("", "", "", "")
    if cidr_block:
        start_ip, end_ip, exclusion_start, exclusion_end = get_usable_ips(cidr_block)

    # Collect Subnet Data
    subnet_data.append({
        "fits_id": fits_id,
        "cidr_block": cidr_block,
        "start_address": start_ip,
        "end_address": end_ip,
        "routers": router_ip,
        "domain_name_servers": "10.180.80.5,10.180.81.5",
        "domain_name": "dom1.infra.int",
        "valid_lifetime": "1",
        "valid_lifetime_unit": "day",
        "exclusion_start_address": exclusion_start,
        "exclusion_end_address": exclusion_end
    })

    # Collect Host Reservation Data
    for match in host_line_pattern.finditer(content):
        host_name_raw, mac_address, ip_address, comment, serial = match.groups()
        hostname = host_name_raw.strip() + "." + DOMAIN_NAME

        # Extract description/model if serial exists
        description = ""
        if comment and serial:
            parts = comment.strip().split("serial")
            if len(parts) >= 1:
                model_candidate = parts[0].strip()
                if " " in model_candidate:
                    description = model_candidate.split(" ", 1)[-1].strip()
                else:
                    description = model_candidate

        reservation_data.append({
            "fits_id": fits_id,
            "cidr_block": cidr_block,
            "hw_address": mac_address.lower(),
            "ip_address": ip_address,
            "hostname": hostname,
            "description": description
        })

# Write to CSV
subnet_df = pd.DataFrame(subnet_data)
reservation_df = pd.DataFrame(reservation_data)

subnet_df.to_csv(input_folder / "dhcp_subnets.csv", index=False)
reservation_df.to_csv(input_folder / "dhcp_reservations.csv", index=False)
print("Subnet and Reservation CSV files generated successfully!")