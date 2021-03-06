class Notifier
  constructor: ->
    @enableNotification = false
    @checkOrRequirePermission()

  hasSupport: ->
    window.webkitNotifications?

  requestPermission: (cb) ->
    window.webkitNotifications.requestPermission (cb)

  setPermission: =>
    if @hasPermission()
      $('#notification-alert a.close').click()
      @enableNotification = true
    else if window.webkitNotifications.checkPermission() is 2
      $('#notification-alert a.close').click()

  hasPermission: ->
    if window.webkitNotifications.checkPermission() is 0
      return true
    else
      return false

  checkOrRequirePermission: =>
    if @hasSupport()
      if @hasPermission()
        @enableNotification = true
      else
        if window.webkitNotifications.checkPermission() isnt 2
          @showTooltip()
    else
      console.log("Desktop notifications are not supported for this Browser/OS version yet.")

  showTooltip: ->
    $('.main-container > .navbar').before("<div class='alert alert-error' id='notification-alert' style='text-align: center;'><a id='link_enable_notifications' href='javascript:;' style='font-weight: bolder;'>点击这里</a> 开启桌面提醒通知功能。 <a class='close' href='javascript:;'>×</a></div>")
    $("#notification-alert").alert()
    $('#notification-alert').on 'click', 'a.close', (e) =>
      e.preventDefault()
      $("#notification-alert").alert('close')
    $('#notification-alert').on 'click', 'a#link_enable_notifications', (e) =>
      e.preventDefault()
      @requestPermission(@setPermission)
    setTimeout ( => $("#notification-alert").alert('close') ), 7000

  visitUrl: (url) ->
    window.location.href = url

  notify: (avatar, title, content, id) ->
    if @enableNotification
      popup = window.webkitNotifications.createNotification(avatar, title, content)
      popup.onclick = ->
        window.parent.focus()
        if id
          viewEle = angular.element(document.getElementById("singleReceiptView"))
          container = angular.element(document.getElementById("single_receipt"))
          viewEle.show(300)
          container.scope().$apply ()->
            container.scope().ctrl.getReceipt(id)
        # alert id

      # if url
      #   popup.onclick = ->
      #     window.parent.focus()
      #     $.notifier.visitUrl(url)
      popup.show()

      setTimeout ( => popup.cancel() ), 12000

window.Notifier = Notifier
