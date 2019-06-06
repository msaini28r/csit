# Copyright (c) 2019 Cisco and/or its affiliates.
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
| Resource | resources/libraries/robot/performance/performance_setup.robot
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR
| ... | NIC_Intel-X710 | DOT1Q | L2XCFWD | BASE | VHOST | 1VM
| ... | VHOST_1024 | LBOND | LBOND_VPP | LBOND_MODE_LACP | LBOND_LB_L34
| ... | LBOND_1L
| ...
| Suite Setup | Run Keywords
| ... | Set up 3-node performance topology with DUT's NIC model | L2
| ... | ${nic_name}
| ... | AND | Set up performance test suite with LACP mode link bonding
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance test with vhost
| ...
| Test Template | Local Template
| ...
| Documentation | *RFC2544: Pkt throughput L2XC test cases with vhost and vpp
| ... | link bonding*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 cross connect. 802.1q
| ... | tagging is applied on link between DUT1 and DUT2.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with VPP
| ... | link bonding (mode LACP, transmit policy l34) on link between DUT1 and
| ... | DUT2 and L2 cross- connect. Qemu VNFs are \
| ... | connected to VPP via vhost-user interfaces. Guest is running VPP l2xc \
| ... | interconnecting vhost-user interfaces, rxd/txd=1024. DUT1/DUT2 is \
| ... | tested with ${nic_name}.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop\
| ... | Rate) with zero packet loss tolerance and throughput PDR (Partial Drop\
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage\
| ... | of packets transmitted. NDR and PDR are discovered for different\
| ... | Ethernet L2 frame sizes using MLRsearch library.\
| ... | Test packets are generated by TG on links to DUTs. TG traffic profile
| ... | contains two L3 flow-groups (flow-group per direction, 254 flows per
| ... | flow-group) with all packets containing Ethernet header, IPv4 header
| ... | with IP protocol=61 and static payload. MAC addresses are matching MAC
| ... | addresses of the TG node interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
| ${nic_name}= | Intel-X710
| ${overhead}= | ${4}
| ${subid}= | 10
| ${tag_rewrite}= | pop-1
| ${nf_dtcr}= | ${1}
| ${nf_dtc}= | ${1}
| ${nf_chains}= | ${1}
| ${nf_nodes}= | ${1}
# Link bonding config
| ${bond_mode}= | lacp
| ${lb_mode}= | l34
# Traffic profile:
| ${traffic_profile}= | trex-sl-3n-ethip4-ip4src254

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config.
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Measure NDR and PDR values using MLRsearch algorithm.\
| | ...
| | ... | *Arguments:*
| | ... | - frame_size - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| | ...
| | [Arguments] | ${frame_size} | ${phy_cores} | ${rxq}=${None}
| | ...
| | Set Test Variable | \${frame_size}
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add PCI devices to all DUTs
| | And Add VLAN Strip Offload switch off between DUTs in 3-node single link topology
| | Set Max Rate And Jumbo And Handle Multi Seg
| | And Apply startup configuration on all VPP DUTs
| | When Initialize L2 xconnect with Vhost-User and VLAN with VPP link bonding in 3-node circular topology
| | ... | ${subid} | ${tag_rewrite} | ${bond_mode} | ${lb_mode}
| | And Configure chains of NFs connected via vhost-user
| | ... | nf_chains=${nf_chains} | nf_nodes=${nf_nodes} | jumbo=${jumbo}
| | ... | use_tuned_cfs=${False} | auto_scale=${True} | vnf=vpp_chain_l2xc
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| tc01-64B-1c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 64B | 1C
| | frame_size=${64} | phy_cores=${1}

| tc02-64B-2c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 64B | 2C
| | frame_size=${64} | phy_cores=${2}

| tc03-64B-4c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 64B | 4C
| | frame_size=${64} | phy_cores=${4}

| tc04-1518B-1c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| tc05-1518B-2c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| tc06-1518B-4c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| tc07-9000B-1c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| tc08-9000B-2c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| tc09-9000B-4c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| tc10-IMIX-1c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| tc11-IMIX-2c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| tc12-IMIX-4c-1lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}
