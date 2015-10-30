#
# Author:: Brendan Germain (brendan.germain@nasdaq.com)
# Copyright:: Copyright (c) 2015 Brendan Germain
# License:: Apache License, Version 2.0

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Ohai.plugin(:LLDP) do
  provides 'lldp'

  depends 'network'

  lldptool = {
    'chassisID' => '1',
    'portID' => '2',
    'sysName' => '5',
    'mngAddr_ipv4' => '8',
    'mngAddr_ipv6' => '8',
    'PVID' => '0x0080c201',
    'MTU' => '0x00120f04'
  }

  collect_data do
    lldp Mash.new

    network['interfaces'].each do |iface, _iface_v|
      next if iface == 'lo'

      lldp[iface] = Mash.new

      lldptool.each_pair do |key, value|
        so = shell_out("lldptool -tni #{iface} -V #{value}")

        break if so.stdout.empty?
        break if so.stdout.include? 'Unknown LLDP command response'
        break if so.stdout.include? 'Device not found or inactive'
        break if so.stdout.include? 'Agent instance for device not found'

        case key
        when 'sysName', 'MTU'
          so.stdout.split("\n").each do |line|
            lldp[iface][key] = Regexp.last_match(1) if line.match(/^\s+(.*)/)
          end
        when 'chassisID'
          so.stdout.split("\n").each do |line|
            lldp[iface][key] = Regexp.last_match(1) if line.match(/MAC:\s+(.*)/)
          end
        when 'portID'
          so.stdout.split("\n").each do |line|
            lldp[iface][key] = Regexp.last_match(1) if line.match(/(?:Ifname|Local):\s+(.*)/)
          end
        when 'mngAddr_ipv4'
          so.stdout.split("\n").each do |line|
            lldp[iface][key] = Regexp.last_match(1) if line.match(/IPv4:\s+(.*)/)
          end
        when 'mngAddr_ipv6'
          so.stdout.split("\n").each do |line|
            lldp[iface][key] = Regexp.last_match(1) if line.match(/IPv6:\s+(.*)/)
          end
        when 'PVID'
          so.stdout.split("\n").each do |line|
            lldp[iface][key] = Regexp.last_match(1) if line.match(/(?:Info|PVID):\s+(.*)/)
          end
        end
      end
    end
  end
end
