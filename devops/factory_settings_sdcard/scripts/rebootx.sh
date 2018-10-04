#!/bin/bash
#
# Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
# For more information visit http://www.chaibio.com
#
# Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
wait_and_reboot () {
	sync &
	sleep 2
	reboot
}

#wait 2 seconds before rebooting to be able to report the reboot to user.
wait_and_reboot &

timeout=120
if [ -z $1 ]
then
	echo "No timeout given. Defaulting to $timeout"
else
	timeout=$1
	echo "waiting for $timeout seconds before forcing reboot"
fi

reboot_after_timeout () {
	sleep $timeout
	echo "Reboot timeoutted!"
        
	reboot -n -f
}

reboot_after_timeout &

exit 0
