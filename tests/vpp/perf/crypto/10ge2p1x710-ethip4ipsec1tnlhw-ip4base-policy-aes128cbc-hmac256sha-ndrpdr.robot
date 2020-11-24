# Copyright (c) 2020 Cisco and/or its affiliates.
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
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR | TNL_1
| ... | IP4FWD | IPSEC | IPSECHW | IPSECTUN | NIC_Intel-X710 | BASE
| ... | AES_128_CBC | HMAC_SHA_256 | HMAC | AES | DRV_VFIO_PCI
| ... | RXQ_SIZE_0 | TXQ_SIZE_0
| ... | ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha
|
| Suite Setup | Setup suite topology interfaces | performance | ipsechw
| Suite Teardown | Tear down suite | performance
| Test Setup | Setup test | performance
| Test Teardown | Tear down test | performance
|
| Test Template | Local Template
|
| Documentation | *IPv4 IPsec tunnel mode performance test suite.*
|
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 on TG-DUTn,
| ... | Eth-IPv4-IPSec on DUT1-DUT2
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with multiple
| ... | IPsec tunnels between them. DUTs get IPv4 traffic from TG, encrypt it
| ... | and send to another DUT, where packets are decrypted and sent back to TG
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop\
| ... | Rate) with zero packet loss tolerance and throughput PDR (Partial Drop\
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage\
| ... | of packets transmitted. NDR and PDR are discovered for different\
| ... | Ethernet L2 frame sizes using MLRsearch library.\
| ... | TG traffic profile contains two L3 flow-groups
| ... | (flow-group per direction, number of flows per flow-group equals to
| ... | number of IPSec tunnels) with all packets
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and
| ... | static payload. MAC addresses are matching MAC addresses of the TG
| ... | node interfaces. Incrementing of IP.dst (IPv4 destination address) field
| ... | is applied to both streams.
| ... | *[Ref] Applicable standard specifications:* RFC4303 and RFC2544.

*** Variables ***
| @{plugins_to_enable}= | dpdk_plugin.so | crypto_native_plugin.so
| ... | crypto_ipsecmb_plugin.so | crypto_openssl_plugin.so
| ${crypto_type}= | HW_DH895xcc
| ${nic_name}= | Intel-X710
| ${nic_driver}= | vfio-pci
| ${nic_rxq_size}= | 0
| ${nic_txq_size}= | 0
| ${nic_pfs}= | 2
| ${nic_vfs}= | 0
| ${osi_layer}= | L3
| ${overhead}= | ${62}
| ${tg_if1_ip4}= | 192.168.10.2
| ${dut1_if1_ip4}= | 192.168.10.1
| ${dut1_if2_ip4}= | 100.0.0.1
| ${dut2_if1_ip4}= | 100.0.0.2
| ${dut2_if2_ip4}= | 192.168.20.1
| ${tg_if2_ip4}= | 192.168.20.2
| ${raddr_ip4}= | 20.0.0.0
| ${laddr_ip4}= | 10.0.0.0
| ${addr_range}= | ${24}
| ${n_tunnels}= | ${1}
# Traffic profile:
| ${traffic_profile}= | trex-stl-3n-ethip4-ip4dst${n_tunnels}

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUTs runs IPsec tunneling AES_CBC_128 / HMAC_256_SHA config.\
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
| | # These are enums (not strings) so they cannot be in Variables table.
| | ${encr_alg}= | Crypto Alg AES CBC 128
| | ${auth_alg}= | Integ Alg SHA 256 128
| |
| | Given Set Max Rate And Jumbo
| | And Add worker threads to all DUTs | ${phy_cores} | ${rxq}
| | And Pre-initialize layer driver | ${nic_driver}
| | And Apply startup configuration on all VPP DUTs
| | When Initialize layer driver | ${nic_driver}
| | And Initialize layer interface
| | And Initialize IPSec in 3-node circular topology
| | And VPP IPsec Add Multiple Tunnels
| | ... | ${nodes} | ${DUT1_${int}2}[0] | ${DUT2_${int}1}[0] | ${n_tunnels}
| | ... | ${encr_alg} | ${auth_alg} | ${dut1_if2_ip4} | ${dut2_if1_ip4}
| | ... | ${laddr_ip4} | ${raddr_ip4} | ${addr_range}
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| 64B-1c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | 64B | 1C
| | frame_size=${64} | phy_cores=${1}

| 64B-2c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | 64B | 2C
| | frame_size=${64} | phy_cores=${2}

| 64B-4c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | 64B | 4C
| | frame_size=${64} | phy_cores=${4}

| 1518B-1c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| 1518B-2c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| 1518B-4c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| 9000B-1c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| 9000B-2c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| 9000B-4c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| IMIX-1c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| IMIX-2c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| IMIX-4c-ethip4ipsec1tnlhw-ip4base-policy-aes128cbc-hmac256sha-ndrpdr
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}
