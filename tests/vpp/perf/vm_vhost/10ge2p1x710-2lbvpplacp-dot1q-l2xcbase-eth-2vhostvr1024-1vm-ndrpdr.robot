# Copyright (c) 2018 Cisco and/or its affiliates.
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
| Force Tags | 3_NODE_DOUBLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR
| ... | NIC_Intel-X710 | DOT1Q | L2XCFWD | BASE | VHOST | 1VM
| ... | VHOST_1024 | LBOND | LBOND_VPP | LBOND_MODE_LACP | LBOND_LB_L34
| ... | LBOND_2L
| ...
| Suite Setup | Run Keywords
| ... | Set up 3-node performance topology with DUT's NIC model with double link between DUTs
| ... | L2 | Intel-X710
| ... | AND | Set up performance test suite with LACP mode link bonding
| ...
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance test with vhost and VM with dpdk-testpmd
| ... | ${min_rate}pps | ${framesize} | ${traffic_profile}
| ... | dut1_node=${dut1} | dut1_vm_refs=${dut1_vm_refs}
| ... | dut2_node=${dut2} | dut2_vm_refs=${dut2_vm_refs}
| ...
| Test Template | Local Template
| ...
| Documentation | *RFC2544: Pkt throughput L2XC test cases with vhost and vpp link bonding*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1=DUT2-TG 3-node circular topology
| ... | with single links between TG and DUT nodes and double link between DUT
| ... | nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 cross connect. 802.1q
| ... | tagging is applied on link between DUT1 and DUT2.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with VPP
| ... | link bonding (mode LACP, transmit policy l34) on link between DUT1 and
| ... | DUT2 and L2 cross- connect. Qemu Guest is connected to VPP via
| ... | vhost-user interfaces. Guest is running DPDK testpmd interconnecting
| ... | vhost-user interfaces using 5 cores pinned to cpus 5-9 and 2048M memory.
| ... | Testpmd is using socket-mem=1024M (512x2M hugepages), 5 cores (1 main
| ... | core and 4 cores dedicated for io), forwarding mode is set to io,
| ... | rxd/txd=1024, burst=64. DUT1, DUT2 are tested with 2p10GE NIC X710
| ... | Fortville by Intel.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop
| ... | Rate) with zero packet loss tolerance or throughput PDR (Partial Drop
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage
| ... | of packets transmitted. NDR and PDR are discovered for different
| ... | Ethernet L2 frame sizes using MLRsearch library.
| ... | Test packets are generated by TG on links to DUTs. TG traffic profile
| ... | contains two L3 flow-groups (flow-group per direction, 254 flows per
| ... | flow-group) with all packets containing Ethernet header, IPv4 header
| ... | with IP protocol=61 and static payload. MAC addresses are matching MAC
| ... | addresses of the TG node interfaces.

*** Variables ***
| ${subid}= | 10
| ${tag_rewrite}= | pop-1
| ${overhead}= | ${4}
# Link bonding config
| ${bond_mode}= | lacp
| ${lb_mode}= | l34
# Socket names
| ${sock1}= | /var/run/vpp/sock-1-1
| ${sock2}= | /var/run/vpp/sock-1-2
# X710 bandwidth limit
| ${s_limit}= | ${10000000000}
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
| | ... | - framesize - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| | ...
| | [Arguments] | ${framesize} | ${phy_cores} | ${rxq}=${None}
| | ...
| | Set Test Variable | ${framesize}
| | Set Test Variable | ${min_rate} | ${10000}
| | ${dut1_vm_refs}= | Create Dictionary
| | ${dut2_vm_refs}= | Create Dictionary
| | Set Test Variable | ${dut1_vm_refs}
| | Set Test Variable | ${dut2_vm_refs}
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add PCI devices to all DUTs
| | And Add VLAN Strip Offload switch off between DUTs in 3-node double link topology
| | ${max_rate} | ${jumbo} = | Get Max Rate And Jumbo And Handle Multi Seg
| | ... | ${s_limit} | ${framesize} | overhead=${overhead}
| | And Apply startup configuration on all VPP DUTs
| | When Initialize L2 xconnect with Vhost-User and VLAN with VPP link bonding in 3-node circular topology
| | ... | ${sock1} | ${sock2} | ${subid} | ${tag_rewrite} | ${bond_mode}
| | ... | ${lb_mode}
| | And Configure guest VMs with dpdk-testpmd connected via vhost-user
| | ... | vm_count=${1} | jumbo=${jumbo} | perf_qemu_qsz=${1024}
| | ... | use_tuned_cfs=${False}
| | And All Vpp Interfaces Ready Wait | ${nodes}
| | Then Find NDR and PDR intervals using optimized search
| | ... | ${framesize} | ${traffic_profile} | ${min_rate} | ${max_rate}

*** Test Cases ***
| tc01-64B-1c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 64B | 1C
| | framesize=${64} | phy_cores=${1}

| tc02-64B-2c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 64B | 2C
| | framesize=${64} | phy_cores=${2}

| tc03-64B-4c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 64B | 4C
| | framesize=${64} | phy_cores=${4}

| tc04-1518B-1c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 1518B | 1C
| | framesize=${1518} | phy_cores=${1}

| tc05-1518B-2c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 1518B | 2C
| | framesize=${1518} | phy_cores=${2}

| tc06-1518B-4c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 1518B | 4C
| | framesize=${1518} | phy_cores=${4}

| tc07-9000B-1c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 9000B | 1C
| | framesize=${9000} | phy_cores=${1}

| tc08-9000B-2c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 9000B | 2C
| | framesize=${9000} | phy_cores=${2}

| tc09-9000B-4c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 9000B | 4C
| | framesize=${9000} | phy_cores=${4}

| tc10-IMIX-1c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | IMIX | 1C
| | framesize=IMIX_v4_1 | phy_cores=${1}

| tc11-IMIX-2c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | IMIX | 2C
| | framesize=IMIX_v4_1 | phy_cores=${2}

| tc12-IMIX-4c-2lbvpplacp-dot1q-l2xcbase-eth-2vhostvr1024-1vm-ndrpdr
| | [Tags] | IMIX | 4C
| | framesize=IMIX_v4_1 | phy_cores=${4}
