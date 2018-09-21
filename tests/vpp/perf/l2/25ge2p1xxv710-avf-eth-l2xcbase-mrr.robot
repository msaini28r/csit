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
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | MRR
| ... | NIC_Intel-XXV710 | ETH | L2XCFWD | BASE | L2XCBASE | DRV_AVF
| ...
| Suite Setup | Run Keywords
| ... | Set up SRIOV 3-node performance topology with DUT's NIC model
| ... | L2 | Intel-XXV710 | AVF
| ... | AND | Set up performance test suite with AVF driver
| ...
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance mrr test
| ...
| Test Template | Local template
| ...
| Documentation | *Raw results L2XC test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology\
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 cross-connect.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 cross-\
| ... | connect. DUT1 and DUT2 tested with 2p25GE NIC XXV710 by Intel with VF\
| ... | enabled.
| ... | *[Ver] TG verification:* In MaxReceivedRate tests TG sends traffic\
| ... | at line rate and reports total received/sent packets over trial period.\
| ... | Test packets are generated by TG on\
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups\
| ... | (flow-group per direction, 254 flows per flow-group) with all packets\
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and static\
| ... | payload. MAC addresses are matching MAC addresses of the TG node\
| ... | interfaces.

*** Variables ***
# XXV710-DA2 bandwidth limit ~50Gbps/2=25Gbps
| ${s_25G} | ${25000000000}
# XXV710-DA2 Mpps limit 37.5Mpps/2=18.75Mpps
| ${s_18.75Mpps} | ${18750000}
# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip4-ip4src254

*** Keywords ***
| Local template
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC config with ${phy_cores} phy
| | ... | core(s).
| | ... | [Ver] Measure MaxReceivedRate for ${framesize}B frames using single\
| | ... | trial throughput test.
| | ...
| | ... | *Arguments:*
| | ... | - framesize - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| | ...
| | [Arguments] | ${framesize} | ${phy_cores} | ${rxq}=${None}
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add DPDK no PCI to all DUTs
| | ${max_rate} | ${jumbo} = | Get Max Rate And Jumbo
| | ... | ${s_25G} | ${framesize} | pps_limit=${s_18.75Mpps}
| | And Apply startup configuration on all VPP DUTs
| | When Initialize AVF interfaces
| | And Initialize L2 xconnect in circular topology
| | Then Traffic should pass with maximum rate
| | ... | ${max_rate}pps | ${framesize} | ${traffic_profile}

*** Test Cases ***
| tc01-64B-1c-avf-eth-l2xcbase-mrr
| | [Tags] | 64B | 1C
| | framesize=${64} | phy_cores=${1}

| tc02-64B-2c-avf-eth-l2xcbase-mrr
| | [Tags] | 64B | 2C
| | framesize=${64} | phy_cores=${2}

| tc03-64B-4c-avf-eth-l2xcbase-mrr
| | [Tags] | 64B | 4C
| | framesize=${64} | phy_cores=${4}

| tc04-1518B-1c-avf-eth-l2xcbase-mrr
| | [Tags] | 1518B | 1C
| | framesize=${1518} | phy_cores=${1}

| tc05-1518B-2c-avf-eth-l2xcbase-mrr
| | [Tags] | 1518B | 2C
| | framesize=${1518} | phy_cores=${2}

| tc06-1518B-4c-avf-eth-l2xcbase-mrr
| | [Tags] | 1518B | 4C
| | framesize=${1518} | phy_cores=${4}

| tc10-IMIX-1c-avf-eth-l2xcbase-mrr
| | [Tags] | IMIX | 1C
| | framesize=IMIX_v4_1 | phy_cores=${1}

| tc11-IMIX-2c-avf-eth-l2xcbase-mrr
| | [Tags] | IMIX | 2C
| | framesize=IMIX_v4_1 | phy_cores=${2}

| tc12-IMIX-4c-avf-eth-l2xcbase-mrr
| | [Tags] | IMIX | 4C
| | framesize=IMIX_v4_1 | phy_cores=${4}
