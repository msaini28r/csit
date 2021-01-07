# Copyright (c) 2021 Cisco and/or its affiliates.
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
|
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR
| ... | NIC_Intel-X710 | ETH | L2BDMACLRN | FEATURE | MACIP | ACL_STATELESS
| ... | IACL | ACL50 | 100K_FLOWS | DRV_VFIO_PCI
| ... | RXQ_SIZE_0 | TXQ_SIZE_0
| ... | eth-l2bdbasemaclrn-macip-iacl50sl-100kflows
|
| Suite Setup | Setup suite topology interfaces | performance
| Suite Teardown | Tear down suite | performance
| Test Setup | Setup test | performance
| Test Teardown | Tear down test | performance | macipacl
|
| Test Template | Local Template
|
| Documentation | *RFC2544: Packet throughput L2BD test cases with ACL*
|
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology\
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 switching of IPv4.
| ... | *[Cfg] DUT configuration:* DUT1 is configured with L2 bridge domain\
| ... | and MAC learning enabled. DUT2 is configured with L2 cross-connects.\
| ... | Required MACIP ACL rules are applied to input paths of both DUT1\
| ... | interfaces. DUT1 and DUT2 are tested with ${nic_name}.\
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop\
| ... | Rate) with zero packet loss tolerance and throughput PDR (Partial Drop\
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage\
| ... | of packets transmitted. NDR and PDR are discovered for different\
| ... | Ethernet L2 frame sizes using MLRsearch library.\
| ... | Test packets are generated by TG on\
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups\
| ... | (flow-group per direction, ${flows_per_dir} flows per flow-group) with\
| ... | all packets containing Ethernet header, IPv4 header with IP protocol=61\
| ... | and static payload. MAC addresses are matching MAC addresses of the TG\
| ... | node interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so | acl_plugin.so
| ${crypto_type}= | ${None}
| ${nic_name}= | Intel-X710
| ${nic_driver}= | vfio-pci
| ${nic_rxq_size}= | 0
| ${nic_txq_size}= | 0
| ${nic_pfs}= | 2
| ${nic_vfs}= | 0
| ${osi_layer}= | L2
| ${overhead}= | ${0}
# ACL test setup
| ${acl_action}= | permit
| ${no_hit_aces_number}= | 50
| ${flows_per_dir}= | 100k
# starting points for non-hitting ACLs
| ${src_ip_start}= | 30.30.30.1
| ${ip_step}= | ${1}
| ${src_mac_start}= | 01:02:03:04:05:06
| ${src_mac_step}= | ${1000}
| ${src_mac_mask}= | 00:00:00:00:00:00
| ${tg_stream1_mac}= | ca:fe:00:00:00:00
| ${tg_stream2_mac}= | fa:ce:00:00:00:00
| ${tg_mac_mask}= | ff:ff:ff:fe:00:00
| ${tg_stream1_subnet}= | 10.0.0.0/15
| ${tg_stream2_subnet}= | 20.0.0.0/15
# traffic profile
| ${traffic_profile}= | trex-stl-3n-ethip4-macsrc100kip4src100k

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config.
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
| | And Apply Startup configuration on all VPP DUTs
| | When Initialize layer driver | ${nic_driver}
| | And Initialize layer interface
| | And Initialize L2 bridge domain with MACIP ACLs in circular topology
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| 64B-1c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | 64B | 1C
| | frame_size=${64} | phy_cores=${1}

| 64B-2c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | 64B | 2C
| | frame_size=${64} | phy_cores=${2}

| 64B-4c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | 64B | 4C
| | frame_size=${64} | phy_cores=${4}

| 1518B-1c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| 1518B-2c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| 1518B-4c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| 9000B-1c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| 9000B-2c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| 9000B-4c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| IMIX-1c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| IMIX-2c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| IMIX-4c-eth-l2bdbasemaclrn-macip-iacl50sl-100kflows-ndrpdr
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}
