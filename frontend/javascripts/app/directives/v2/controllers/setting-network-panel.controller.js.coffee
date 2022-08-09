window.App.controller 'SettingNetworkPanelCtrl', [
  '$scope'
  '$rootScope'
  'User'
  '$state'
  'NetworkSettingsService'
  '$interval'
  '$timeout'
  ($scope, $rootScope, User, $state, NetworkSettingsService, $interval, $timeout) ->
    # All available wifi networks
    $scope.wifiNetworks = {}
    # Current active wifi network [connected to]
    $scope.currentWifiSettings = {}
    # Ethernet settings
    $scope.ethernetSettings = {}
    $scope.ethernetToggle = true
    # Incase no wifi adapter is present in the machine
    $scope.wirelessError = false
    $scope.macAddress = NetworkSettingsService.macAddress or null
    $scope.userSettings = $.jStorage.get('userNetworkSettings')
    # If network is on/off
    $scope.wifiNetworkStatus = if $scope.userSettings.wifiSwitchOn == undefined then false else $scope.userSettings.wifiSwitchOn
    NetworkSettingsService.intervalScanKey = null
    # Initiate wifi network service;
    $scope.currentInterval = 1000
    if $scope.userSettings.wifiSwitchOn
      NetworkSettingsService.getSettings 5000

    #Select Network    
    $scope.autoSetting = true
    $scope.buttonValue = 'Connect'
    $scope.buttonEnabled = false
    $scope.IamConnected = false
    $scope.statusMessage = ''
    $scope.currentNetwork = {}
    $scope.connectedSsid = ''
    $scope.wifiNetworkType = null
    $scope.editEthernetData = {}
    $scope.name = ''
    $scope.selectedWifiNow = null
    $scope.errors = 
      wifi_password: ''
      wifi_ssid: ''

    $scope.wanOption = 'wifi'
    $scope.hotspotErrors = 
      ssid: ''
      password: ''

    $scope.hotspotInfo = 
      ssid: ''
      password: ''
    $scope.isHotspotActive = false

    ###*
      'new_wifi_result' this event is fired up when new wifi status is sent from the
      server.
    ###

    $scope.$on 'new_wifi_result', ->
      $scope.wirelessError = false
      $scope.wifiNetworkStatus = NetworkSettingsService.userSettings.wifiSwitchOn
      $scope.currentWifiSettings = NetworkSettingsService.connectedWifiNetwork

      if NetworkSettingsService.connectedWifiNetwork.state.status == 'connected'
        $scope.statusMessage = ''
        $scope.currentNetwork = NetworkSettingsService.connectedWifiNetwork
        $scope.editEthernetData = $scope.currentNetwork.state
        if $scope.currentNetwork.settings['dns-nameservers']
          $scope.editEthernetData.dns_nameservers = $scope.currentNetwork.settings['dns-nameservers'].split(' ')[0]
        $scope.connectedSsid = NetworkSettingsService.connectedWifiNetwork.settings['wpa-ssid'] or NetworkSettingsService.connectedWifiNetwork.settings.wireless_essid
        $scope.connectedSsid = $scope.connectedSsid.replace new RegExp('"', 'g'), ''
        $scope.IamConnected = if $scope.name == $scope.connectedSsid then true else false
      else
        $scope.configureAsStatus NetworkSettingsService.connectedWifiNetwork.state.status

      return

    ###*
      'wifi_adapter_error' this event is fired up when wifi adapter is not present or having some problem.
    ###

    $rootScope.$on 'wifi_adapter_error', ->
      $scope.whenNoWifiAdapter()
      return

    ###*
      'wifiNetworkStatus' This watch is executed when wifiNetworkStatus is changed, This one is changed when
      we toggle wifi on off switch. And to be executed switchStatus shouldbe inverse of the $scope.userSettings.wifiSwitchOn.
      This is enforced so that we dont have to call turnOnWifi() or turnOffWifi() at the page load.
    ###

    $scope.$watch 'wifiNetworkStatus', (switchStatus) ->
      if $scope.wirelessError == false
        if switchStatus == true and $scope.userSettings.wifiSwitchOn == false
          $scope.turnOnWifi()
        else if switchStatus == false and $scope.userSettings.wifiSwitchOn == true
          $scope.turnOffWifi()
          $scope.onCancel()

      else
        NetworkSettingsService.stopInterval()
        NetworkSettingsService.getSettings 5000
      return
    $scope.$watch 'wifiNetworks', (network) ->
      if $scope.wirelessError == false
        if $scope.wifiNetworkStatus == true
          if network.length > 0 and ($scope.currentInterval == 1000 or NetworkSettingsService.intervalScanKey == null)
            $scope.stopInterval()
            $scope.currentInterval = 10000
            NetworkSettingsService.intervalScanKey = $interval($scope.findWifiNetworks, $scope.currentInterval)
          else if network.length == 0 and ($scope.currentInterval == 10000 or NetworkSettingsService.intervalScanKey == null)
            $scope.stopInterval()
            $scope.currentInterval = 1000
            NetworkSettingsService.intervalScanKey = $interval($scope.findWifiNetworks, $scope.currentInterval)
        else
          $scope.stopInterval()
      else
        $scope.stopInterval()
      return
    $scope.$on 'wifi_adapter_reconnected', (evt, wifiData) ->
      $scope.wifiNetworkStatus = true
      $scope.wirelessError = false
      $scope.macAddress = wifiData.state.macAddress
      $scope.init()
      return
    $scope.$on 'wifi_stopped', ->
      #console.log("wifi stopped");
      #scope.inProgress = false;
      #$timeout(function(){
      $scope.wifiNetworks = $scope.currentWifiSettings = {}
      #}, 1000);
      return

    ###*
      This function takes care of the things when there is no wifi adapter or wifi adapter is having some error.
    ###

    $scope.whenNoWifiAdapter = ->
      $scope.wirelessError = true
      $scope.wifiNetworkStatus = false
      $scope.wirelessErrorData = NetworkSettingsService.wirelessErrorData
      $scope.wifiNetworks = $scope.currentWifiSettings = {}
      # $scope.userSettings.wifiSwitchOn = false;
      # $.jStorage.set('userNetworkSettings', $scope.userSettings);
      return

    ###*
      This methode turns off wifi, It empties wifiNetworks and currentWifiSettings, So that immediately
      interface changes. It also reloads userSettings from localstorage.
    ###

    $scope.turnOffWifi = ->
      stopped = NetworkSettingsService.stop()
      $scope.wifiNetworks = $scope.currentWifiSettings = {}
      stopped.then ((result) ->
        $scope.userSettings = $.jStorage.get('userNetworkSettings')
        return
      ), (err) ->
        console.log 'Could not disconnect wifi', err
        return
      return

    ###*
      This method starts the wifi, Then calls init() and brings the network data and reloads userSettings
      from localstorage
    ###

    $scope.turnOnWifi = ->
      started = NetworkSettingsService.restart()
      started.then ((result) ->
        $scope.userSettings = $.jStorage.get('userNetworkSettings')
        $scope.init()
        return
      ), (err) ->
        NetworkSettingsService.processOnError err
        console.log 'Could not connect wifi', err
        return
      return

    ###*
      This method looks for all the wifi networks around the vicinity and add them to wifiNetworks
    ###

    $scope.findWifiNetworks = ->
      if !NetworkSettingsService.wirelessError and $scope.userSettings.wifiSwitchOn
        NetworkSettingsService.getWifiNetworks().then (result) ->
          if result.data
            $scope.wifiNetworks = result.data.scan_result
          return
      return

    $scope.stopInterval = ->
      $interval.cancel NetworkSettingsService.intervalScanKey
      NetworkSettingsService.intervalScanKey = null
      return

    ###*
      Initiate the primary things like ethernet status, wifiNetworkStatus and all the wifi networks around the room.
    ###

    $scope.init = ->
      $scope.ethernetSettings = NetworkSettingsService.connectedEthernet
      NetworkSettingsService.getEthernetStatus()
      if NetworkSettingsService.intervalKey == null
        NetworkSettingsService.getSettings 5000
      if NetworkSettingsService.wirelessError
        $scope.whenNoWifiAdapter()
        return
      if $scope.userSettings.wifiSwitchOn
        $scope.currentWifiSettings = NetworkSettingsService.connectedWifiNetwork
        NetworkSettingsService.intervalScanKey = $interval($scope.findWifiNetworks, $scope.currentInterval)

        # If we refresh right on this page, mac address may take some time to load in service , so we wait to load here.
        if $scope.macAddress == null and NetworkSettingsService.wirelessError == true
          waitForMac = $interval((->
            if NetworkSettingsService.macAddress != null
              $scope.macAddress = NetworkSettingsService.macAddress
              $interval.cancel waitForMac
              waitForMac = null
            return
          ), 1000)
      return

    $scope.init()
    $scope.$on '$destroy', (network) ->
      $scope.stopInterval()
      if NetworkSettingsService.intervalKey
        NetworkSettingsService.stopInterval()
      return

    $scope.$watch 'autoSetting', (val, oldVal) ->
      if val == false
        $scope.buttonValue = 'Save Changes'
      if val == true and $scope.currentNetwork.settings and $scope.currentNetwork.settings.type == 'static'
        $scope.changeToAutomatic()
      return

    $scope.updateConnectedWifi = (key) ->
      # When our selected wifi network is the one which is connected already.
      wifiConnection = NetworkSettingsService.connectedWifiNetwork
      if wifiConnection.settings and wifiConnection.settings[key]
        $scope.connectedSsid = wifiConnection.settings[key].replace(new RegExp('"', 'g'), '')
        if $scope.name == $scope.connectedSsid
          if wifiConnection.state.status == 'connected'
            $scope.currentNetwork = wifiConnection
            $scope.editEthernetData = $scope.currentNetwork.state
            if $scope.currentNetwork.settings['dns-nameservers']
              $scope.editEthernetData.dns_nameservers = $scope.currentNetwork.settings['dns-nameservers'].split(' ')[0]
            $scope.IamConnected = true
            # We assign this so that, It shows data when we select
            #a wifi network which is already being connected.
          else if wifiConnection.state.status == 'connecting'
            $scope.buttonValue = 'Connecting'
      return

    verifyWifiCredentials = ->
      if $scope.wifiNetworkType == 'wpa2 802.1x' || $scope.wifiNetworkType == 'wpa1 802.1x'
        $scope.errors.wifi_ssid = if $scope.credentials['wpa-identity'] then '' else 'Cannot be blank.'
        $scope.errors.wifi_password = if $scope.credentials['wpa-password'] then '' else 'Cannot be blank.'

      else if $scope.wifiNetworkType=='wpa2 psk' || $scope.wifiNetworkType=='wpa1 psk'
        $scope.errors.wifi_ssid = ''
        $scope.errors.wifi_password = if $scope.credentials['wpa-psk'] then '' else 'Cannot be blank.'
      else if $scope.wifiNetworkType=='wep'
        $scope.errors.wifi_ssid = ''
        $scope.errors.wifi_password = if $scope.credentials['wireless_key'] then '' else 'Cannot be blank.'
      else
        $scope.errors.wifi_ssid = ''
        $scope.errors.wifi_password = ''

      return if $scope.errors.wifi_ssid == '' and $scope.errors.wifi_password == '' then true else false

    $scope.connectWifi = ->
      console.log $scope.credentials
      # for checking later in 200.
      if $scope.buttonValue == 'Connecting' || !verifyWifiCredentials()
        return

      NetworkSettingsService.connectWifi($scope.credentials).then ((data) ->
        $scope.statusMessage = ''
        $scope.buttonValue = 'Connecting'
        return
      ), (err) ->
        console.log err
        return
      return

    $scope.configureAsStatus = (status) ->
      if $scope.selectedWifiNow?.ssid == NetworkSettingsService.connectedWifiNetwork.settings?['wpa-ssid']
        switch status
          when 'not_connected'
            $scope.buttonValue = 'Connect'
            $scope.statusMessage = ''
          when 'connecting'
            $scope.buttonValue = 'Connecting'
          when 'connection_error'
            $scope.buttonValue = 'Connect'
            $scope.statusMessage = 'Unable to connect'
          when 'authentication_error'
            $scope.buttonValue = 'Connect'
            $scope.statusMessage = 'Authentication error'
      else
          $scope.buttonValue = 'Connect'
          $scope.statusMessage = ''
      return

    $scope.connectEthernet = ->
      $scope.statusMessage = ''
      $scope.buttonValue = 'Connecting'
      $scope.buttonEnabled = false
      NetworkSettingsService.connectToEthernet($scope.editEthernetData).then ((result) ->
        NetworkSettingsService.getEthernetStatus()
        # Get the new ip details as soon as we connect to new ethernet.
        $scope.autoSetting = true
        return
      ), (err) ->
        return
      $timeout $scope.goToNewIp, 5000
      return

    $scope.goToNewIp = ->
      url = 'http://' + $scope.editEthernetData.address
      $window.location.href = url
      return

    $scope.changeToAutomatic = ->
      ethernet = {}
      ethernet.type = 'dhcp'
      NetworkSettingsService.changeToAutomatic(ethernet).then ((result) ->
        console.log result
        NetworkSettingsService.getEthernetStatus()
        # Get the new ip details as soon as we connect to new ethernet.
        $scope.autoSetting = true
        return
      ), (err) ->
        console.log err
        return
      return

    $scope.initNetwork = ->

      if $scope.selectedWifiNow
        # if our selection is a wifi network.
        try
          if NetworkSettingsService.connectedWifiNetwork and NetworkSettingsService.connectedWifiNetwork.state?.status == 'connecting'
            $scope.connectedSsid = NetworkSettingsService.connectedWifiNetwork.settings['wpa-ssid'] or NetworkSettingsService.connectedWifiNetwork.settings.wireless_essid
            $scope.connectedSsid = $scope.connectedSsid.replace new RegExp('"', 'g'), ''
            if $scope.name == $scope.connectedSsid
              $scope.buttonValue = 'Connecting'
        catch err
          console.log 'connectedWifiNetwork yet to load'
        if $scope.selectedWifiNow.encryption == 'wpa2 psk'
          $scope.wifiNetworkType = 'wpa2 psk'
          $scope.credentials =
            'wpa-ssid': $scope.name
            'wpa-psk': ''
            'type': 'dhcp'
          $scope.updateConnectedWifi 'wpa-ssid'
        else if $scope.selectedWifiNow.encryption == 'wpa1 psk'
          $scope.wifiNetworkType = 'wpa1 psk'
          $scope.credentials =
            'wpa-ssid': $scope.name
            'wpa-psk': ''
            'type': 'dhcp'
          $scope.updateConnectedWifi 'wpa-ssid'
        else if $scope.selectedWifiNow.encryption == 'wpa2 802.1x'
          $scope.wifiNetworkType = 'wpa2 802.1x'
          $scope.credentials =
            'wpa-ssid': $scope.name
            'wpa-identity': ''
            'wpa-password': ''
            'type': 'dhcp'
          $scope.updateConnectedWifi 'wpa-ssid'
        else if $scope.selectedWifiNow.encryption == 'wpa1 802.1x'
          $scope.wifiNetworkType = 'wpa1 802.1x'
          $scope.credentials =
            'wpa-ssid': $scope.name
            'wpa-identity': ''
            'wpa-password': ''
            'type': 'dhcp'
          $scope.updateConnectedWifi 'wpa-ssid'
        else if $scope.selectedWifiNow.encryption == 'wep'
          $scope.wifiNetworkType = 'wep'
          $scope.credentials =
            'wireless_essid': $scope.name
            'wireless_key': ''
            'type': 'dhcp'
          $scope.updateConnectedWifi 'wireless_essid'
        else if $scope.selectedWifiNow.encryption == 'none'
          $scope.wifiNetworkType = 'none'
          $scope.credentials =
            'wireless_essid': $scope.name
            'type': 'dhcp'
          $scope.updateConnectedWifi 'wireless_essid'
        else
          $scope.wifiNetworkType = ''

        if NetworkSettingsService.connectedWifiNetwork
          if NetworkSettingsService.connectedWifiNetwork.state?.status == 'connected'
            $scope.statusMessage = ''
            $scope.currentNetwork = NetworkSettingsService.connectedWifiNetwork
            $scope.editEthernetData = $scope.currentNetwork.state
            if $scope.currentNetwork.settings['dns-nameservers']
              $scope.editEthernetData.dns_nameservers = $scope.currentNetwork.settings['dns-nameservers'].split(' ')[0]
            $scope.connectedSsid = NetworkSettingsService.connectedWifiNetwork.settings['wpa-ssid'] or NetworkSettingsService.connectedWifiNetwork.settings.wireless_essid
            $scope.connectedSsid = $scope.connectedSsid.replace new RegExp('"', 'g'), ''
            $scope.IamConnected = if $scope.name == $scope.connectedSsid then true else false
          else if NetworkSettingsService.connectedWifiNetwork.state
            $scope.configureAsStatus NetworkSettingsService.connectedWifiNetwork.state.status

      else if $scope.selectedWifiNow == null and NetworkSettingsService.connectedEthernet.interface == 'eth0'
        #If we selected an ethernet.
        # Configuring values if selected network is Ethernet.
        console.log 'Ethernet territory'
        ethernetConnection = NetworkSettingsService.connectedEthernet
        if ethernetConnection.state
          if $scope.name == 'ethernet'
            $scope.IamConnected = true
            $scope.currentNetwork = ethernetConnection
            # Add dns server and gateway into object if they dont exist.
            $scope.editEthernetData = $scope.currentNetwork.state
            $scope.editEthernetData.type = $scope.currentNetwork.settings.type
            if $scope.currentNetwork.settings.type == 'static'
              $scope.autoSetting = false
            else
              $scope.autoSetting = true
            if !$scope.currentNetwork.settings.gateway
              $scope.editEthernetData.gateway = '0.0.0.0'
            else
              $scope.editEthernetData.gateway = $scope.currentNetwork.settings.gateway
            if !$scope.currentNetwork.settings['dns-nameservers']
              $scope.editEthernetData['dns-nameservers'] = '0.0.0.0'
            else
              $scope.editEthernetData['dns-nameservers'] = $scope.currentNetwork.settings['dns-nameservers'].split(' ')[0]
      else
        $timeout (->
          $scope.selectedWifiNow = NetworkSettingsService.listofAllWifi[$scope.name] or null
          #
          $scope.initNetwork()
          return
        ), 500

      return

    ###*
      'ethernet_detected' this event is fired up when ethernet is detected in the machine.
    ###

    $scope.$on 'ethernet_detected', ->
      $scope.ethernetSettings = NetworkSettingsService.connectedEthernet
      $scope.initNetwork()
      return

    $scope.onSelectNetwork = (network) ->
      $scope.name = network
      $scope.selectedWifiNow = NetworkSettingsService.listofAllWifi[$scope.name] or null
      $scope.initNetwork()
      $scope.errors.wifi_password = ''

      # Select Network
      if network == 'ethernet'
        $scope.buttonValue = 'Save Changes'
        $scope.buttonEnabled = false
        $scope.oriEditEthernetData = angular.copy $scope.editEthernetData
      else
        $scope.buttonValue = 'Connect'
      return

    $scope.onCancel = () ->
      if $scope.name == 'ethernet'
        NetworkSettingsService.connectedEthernet.state = angular.copy $scope.oriEditEthernetData

      $scope.name = ''
      $scope.selectedWifiNow = null

    $scope.isConnectedNetwork = (ssid) ->
      if $scope.currentWifiSettings.state && $scope.currentWifiSettings.state.status == "connected"
        _ssid = $scope.currentWifiSettings.settings["wpa-ssid"] || $scope.currentWifiSettings.settings.wireless_essid
        connectedNetworkSsid = _ssid.replace(new RegExp('"', 'g'), "")
        return connectedNetworkSsid == ssid
      return false

    $scope.restartWifi = ->
      stopped = NetworkSettingsService.stop()
      $scope.wifiNetworks = $scope.currentWifiSettings = {}
      stopped.then ((result) ->
        $scope.userSettings = $.jStorage.get('userNetworkSettings')
        $scope.turnOnWifi()
        return
      ), (err) ->
        console.log 'Could not disconnect wifi', err
        return
      return

    ## Wan Options
    $scope.onChangeWanOption = () ->
      $scope.wanOption = if $scope.wanOption == 'wifi' then 'hotspot' else 'wifi'
      if !$scope.wifiNetworkStatus
        $scope.wifiNetworkStatus = true
      if $scope.isHotspotActive
        $scope.restartWifi()

    verifyHotspotCredentials = ->
      $scope.hotspotErrors.ssid = if $scope.hotspotInfo.ssid then '' else 'Cannot be blank.'
      $scope.hotspotErrors.password = if $scope.hotspotInfo.password.length < 8 then 'Must be at least 8 characters' else ''
      return if $scope.hotspotErrors.ssid == '' and $scope.hotspotErrors.password == '' then true else false

    $scope.onHotspotClick = () ->
      if !verifyHotspotCredentials()
        return

      if !$scope.isHotspotActive
        NetworkSettingsService.createHotspot($scope.hotspotInfo).then ((data) ->
          $scope.isHotspotActive = true
          return
        ), (err) ->
          console.log err
          return
      else
        $scope.isHotspotActive = false
        $scope.hotspotInfo = 
          ssid: ''
          password: ''

    $scope.onIPFieldChange = (e) ->
      if $scope.buttonValue != 'Connecting'
        $scope.buttonEnabled = true
]
