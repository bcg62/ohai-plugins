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

Ohai.plugin(:IPMI) do
  provides 'ipmi'

  collect_data do

    so = shell_out("ipmitool lan print")
    
    if so.stdout =~ /IP Address\s+: ([0-9.]+).*MAC Address\s+: ([a-z0-9:]+)/m
      
      ipmi Mash.new
      ipmi[:address] = $1
      ipmi[:mac_address] = $2

    end
  end
end
