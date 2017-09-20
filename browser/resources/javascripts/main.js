/*
 * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

jQuery.fn.center = function() {
	this.css("position", "absolute");
	this.css("top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) +
		$(window).scrollTop()) + "px");
	this.css("left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) +
		$(window).scrollLeft()) + "px");
	return this;
}

$(document).ready(function() {

	// This part was written to align the image and no more used.
	/*setTimeout(function() {
		$('#splash').center()
	}, 1);
    $(window).bind('resize', function() {
        $('#splash').center({transition:0});
    });*/

	var interval = setInterval(function() {
		checkConnection();
	}, 10000);



	var checkConnection = function() {
		$.get("http://localhost:8000/network/eth0")
			.done(function(data) {
				if (data.state.address) {
					//$("#ip-address").text("IP ADDRESS: " + data.state.address);
					assignIp(data);
				} else {
					$.get("http://localhost:8000/network/wlan")
						.done(function(data) {
							if (data.state.address) {
								assignIp(data);
							} else {
								noConnection();
							}
						})
						.fail(function() {
							noConnection();
						});
				}
			})
			.fail(function() {
				$.get("http://localhost:8000/network/wlan")
					.done(function(data) {
						if (data.state.address) {
							assignIp(data);
						} else {
							noConnection();
						}
					})
					.fail(function() {
						noConnection();
					});
			});
	}

	checkConnection();

	var assignIp = function(data) {
		$(".span-message").hide();
		$(".ip-text").show().text("IP ADDRESS: ");
		$(".ip-value").show().text(data.state.address);
	}

	var noConnection = function() {
		$(".ip-text").hide();
		$(".ip-value").hide();
		$(".span-message").show().text("No network connection");
	}

	var shown = false;
	var getDevice = function() {
		$.get("http://localhost:80/device")
			.done(function(data) {
				//if(typeof (data.software.version) != 'undefined' ){
					if (data && data.software && data.software.version) {
						$(".version-text").text("V.   ").show();
						$(".version-value").text(data.software.version).show();
					//clearInterval(insure); // Now we keep looking if we have connection.
					}

				//}
				if (data.serial_number) {
					$(".serial-value").text(data.serial_number).show();
					$(".serial-text").text("SERIAL:").show();
				}
				shown = true;
			})
			.fail(function() {
				if (shown) {
					$(".serial-value").hide();
					$(".serial-text").hide();
					$(".version-text").text("Server Failure");
					$(".version-value").hide();
				}
			});
	}

	getDevice();

	var insure = setInterval(function() {
		getDevice();
	}, 10000);

});
