# Copyright (c) 2021 PANTHEON.tech s.r.o.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

*** Settings ***
| Resource | resources/libraries/robot/shared/default.robot
| Resource | resources/libraries/robot/crypto/ipsec.robot
|
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR | IP4FWD
| ... | SCALE | IPSEC | IPSECSW | IPSECSPD | SPD_OUTBOUND | SPD_FLOW_CACHE
| ... | SPE_1000 | NOCRYPTO
| ... | NIC_Intel-X710 | DRV_VFIO_PCI | RXQ_SIZE_0 | TXQ_SIZE_0
| ... | ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto
|
| Suite Setup | Setup suite topology interfaces | performance
| Suite Teardown | Tear down suite | performance
| Test Setup | Setup test | performance
| Test Teardown | Tear down test | performance
|
| Test Template | Local Template
|
| Documentation | *RFC4301: SPD lookup performance*
|
| ... | *[Top] Network Topologies:* TG-DUT1-TG 2-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for IPv4 routing.
| ... | *[Cfg] DUT configuration:* DUT1 is configured with IPv4 routing, two
| ... | static IPv4 /24 route entries, one SPD on each outbound interface in
| ... | each direction and ${rule amount} SPD entry(ies) in each SPD. Only
| ... | outbound traffic is matched and only the last rule is the matching
| ... | rule. SPD flow-cache for IPv4 outbound traffic is enabled.
| ... | DUT1 tested with ${nic_name}.\
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop\
| ... | Rate) with zero packet loss tolerance and throughput PDR (Partial Drop\
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage\
| ... | of packets transmitted. NDR and PDR are discovered for different\
| ... | Ethernet L2 frame sizes using MLRsearch library.\
| ... | Test packets are generated by TG on links to DUTs. TG traffic profile
| ... | contains two L3 flow-groups (flow-group per direction, 253 flows per
| ... | flow-group) with all packets containing Ethernet header, IPv4 header
| ... | with IP protocol=61 and static payload. MAC addresses are matching MAC
| ... | addresses of the TG node interfaces. The DUT does SPD lookup with only
| ... | the lowest priority rule matching the traffic. The action of the
| ... | matching rule is BYPASS. No encryption or authentication is done.
| ... | *[Ref] Applicable standard specifications:* RFC4301 and RFC2544.

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so | perfmon_plugin.so
| ${crypto_type}= | ${None}
| ${nic_name}= | Intel-X710
| ${nic_driver}= | vfio-pci
| ${nic_rxq_size}= | 0
| ${nic_txq_size}= | 0
| ${nic_pfs}= | 2
| ${nic_vfs}= | 0
| ${osi_layer}= | L3
| ${overhead}= | ${0}
| ${remote_addr_range_ip4}= | 20.20.20.0/24
| ${local_addr_range_ip4}= | 10.10.10.0/24
| ${rule_amount}= | ${1000}
# Traffic profile
| ${traffic_profile}= | trex-stl-2n-ethip4-ip4src253

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with IPsec SPD rules.\
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Measure NDR and PDR values using MLRsearch algorithm.\
| |
| | ... | *Arguments:*
| | ... | - frame_size - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| |
| | [Arguments] | ${frame_size} | ${phy_cores} | ${rxq}=${None}
| |
| | Set Test Variable | \${frame_size}
| |
| | Given Set Max Rate And Jumbo
| | And Add worker threads to all DUTs | ${phy_cores} | ${rxq}
| | And Pre-initialize layer driver | ${nic_driver}
| | And Enable SPD flow cache IPv4 Outbound
| | And Apply startup configuration on all VPP DUTs
| | When Initialize layer driver | ${nic_driver}
| | And Initialize layer interface
| | And Initialize IPv4 forwarding in circular topology
| | And VPP IPsec create SPDs match nth entry
| | ... | ${dut1} | ${DUT1_${int}2}[0] | ${DUT1_${int}1}[0] | ${rule_amount}
| | ... | ${local_addr_range_ip4} | ${remote_addr_range_ip4}
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| 64B-1c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | 64B | 1C
| | frame_size=${64} | phy_cores=${1}

| 64B-2c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | 64B | 2C
| | frame_size=${64} | phy_cores=${2}

| 64B-4c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | 64B | 4C
| | frame_size=${64} | phy_cores=${4}

| 1518B-1c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| 1518B-2c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| 1518B-4c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| 9000B-1c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| 9000B-2c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| 9000B-4c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| IMIX-1c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| IMIX-2c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| IMIX-4c-ethip4ipsec1000spe-cache-ip4base-policy-outbound-nocrypto-ndrpdr
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}