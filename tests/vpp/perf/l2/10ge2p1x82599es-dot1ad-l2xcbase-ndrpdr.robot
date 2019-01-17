# Copyright (c) 2019 PANTHEON.tech and/or its affiliates.
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
| Resource | resources/libraries/robot/l2/tagging.robot
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR
| ... | NIC_Intel-82599ES | L2XCFWD | BASE | DOT1AD
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L2 | Intel-82599ES
| ...
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance discovery test | ${min_rate}pps
| ... | ${framesize} | ${traffic_profile}
| ...
| Test Template | Local Template
| ...
| Documentation | *RFC2544: Pkt throughput L2XC with 802.1ad test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 xconnect.
| ... | 802.1ad tagging is applied on link between DUT1 and DUT2 with inner 4B
| ... | vlan tag (id=100) and outer 4B vlan tag (id=200).
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 cross-
| ... | connect. DUT1 and DUT2 tested with 2p10GE NIC 82599ES by Intel.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop
| ... | Rate) with zero packet loss tolerance or throughput PDR (Partial Drop
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage
| ... | of packets transmitted. NDR and PDR are discovered for different
| ... | Ethernet L2 frame sizes using MLRsearch library.
| ... | Test packets are generated by TG on
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups
| ... | (flow-group per direction, 253 flows per flow-group) with all packets
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and
| ... | static payload. MAC addresses are matching MAC addresses of the TG
| ... | node interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
| ${subid}= | 10
| ${outer_vlan_id}= | 100
| ${inner_vlan_id}= | 200
| ${type_subif}= | two_tags
| ${tag_rewrite}= | pop-2
| ${overhead}= | ${8}
# 82599ES bandwidth limit
| ${s_limit}= | ${10000000000}
# Traffic profile:
| ${traffic_profile}= | trex-sl-3n-ethip4-ip4src254

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC forwarding config.
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
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add PCI devices to all DUTs
| | ${max_rate} | ${jumbo} = | Get Max Rate And Jumbo And Handle Multi Seg
| | ... | ${s_limit} | ${framesize} | overhead=${overhead}
| | And Apply startup configuration on all VPP DUTs
| | And Set interfaces in path up
| | When Initialize VLAN sub-interfaces in 3-node circular topology
| | ... | ${dut1} | ${dut1_if2} | ${dut2} | ${dut2_if1} | ${subid}
| | ... | ${outer_vlan_id} | ${inner_vlan_id} | ${type_subif}
| | And Configure L2 tag rewrite method on interfaces
| | ... | ${dut1} | ${subif_index_1} | ${dut2} | ${subif_index_2}
| | ... | ${tag_rewrite}
| | And Connect interfaces and VLAN sub-interfaces using L2XC
| | ... | ${dut1} | ${dut1_if1} | ${subif_index_1}
| | ... | ${dut2} | ${dut2_if2} | ${subif_index_2}
| | Then Find NDR and PDR intervals using optimized search
| | ... | ${framesize} | ${traffic_profile} | ${min_rate} | ${max_rate}

*** Test Cases ***
| tc01-64B-1c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | 64B | 1C
| | framesize=${64} | phy_cores=${1}

| tc02-64B-2c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | 64B | 2C
| | framesize=${64} | phy_cores=${2}

| tc03-64B-4c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | 64B | 4C
| | framesize=${64} | phy_cores=${4}

| tc04-1518B-1c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | 1518B | 1C
| | framesize=${1518} | phy_cores=${1}

| tc05-1518B-2c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | 1518B | 2C
| | framesize=${1518} | phy_cores=${2}

| tc06-1518B-4c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | 1518B | 4C
| | framesize=${1518} | phy_cores=${4}

| tc07-9000B-1c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | 9000B | 1C
| | framesize=${9000} | phy_cores=${1}

| tc08-9000B-2c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | 9000B | 2C
| | framesize=${9000} | phy_cores=${2}

| tc09-9000B-4c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | 9000B | 4C
| | framesize=${9000} | phy_cores=${4}

| tc10-IMIX-1c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | IMIX | 1C
| | framesize=IMIX_v4_1 | phy_cores=${1}

| tc11-IMIX-2c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | IMIX | 2C
| | framesize=IMIX_v4_1 | phy_cores=${2}

| tc12-IMIX-4c-dot1ad-l2xcbase-ndrpdr
| | [Tags] | IMIX | 4C
| | framesize=IMIX_v4_1 | phy_cores=${4}
