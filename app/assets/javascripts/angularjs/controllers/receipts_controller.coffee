@ReceiptsController = ['$scope', '$http', 'Receipt', ($scope, $http, Receipt) ->
  $scope.read_receipts = Receipt.get('read')
  $scope.unread_receipts = Receipt.get('unread')

  $scope.fetch_attachments = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    unless post.attachments
      receipt.attachments_loading = true
      $http.get("/posts/#{post.id}/attachments").success((data) ->
        receipt.attachments_loading = false
        post.attachments = data.attachments
      )

  $scope.fetch_unread_receipts = (receipt) ->
    post = receipt.post
    unless post.unread_receipts
      $http.get("/posts/#{post.id}/unread_receipts").success((data) ->
        post.unread_receipts = data.unread_receipts
      )

  $scope.fetch_comments = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    unless post.comments
      $http.get("/posts/#{post.id}/comments").success((data) ->
        post.comments = data.comments
      )

  $scope.createComments = (receipt, e) ->
    post = receipt.post
    comment =
      body: post.commentBody
    $http.post("/posts/#{post.id}/comments", { comment: comment })
    .success (data) ->
      angular.element(e.target).prev().click()
      post.comments.unshift data.comment
    .error (data) ->
      fixed_alert('评论失败')

  $scope.form = {}

  $scope.getValueInObj = (input,collection)->
    switch input.type
      when "Field::TextField","Field::NumberField","Field::TextArea"
        return collection.objOfProperty("key",input.identifier).value

      when "Field::RadioButton"
        option_id = collection.objOfProperty("key",input.identifier).value
        return option_id and input.options.objOfProperty("id", option_id).value
        
      when "Field::CheckBox"
        _result = []
        option_ids = collection.objOfProperty("key",input.identifier).value
        for _i in option_ids
          _result.push(input.options.objOfProperty("id", _i).value)
        return _result.join(",")
        

  $scope.set_form_collections = (receipt)->
    $scope.form = receipt.post.forms.first()
    $("#form_collections").show()

  $scope.send_sms_notifications = (receipt,$event)->
    post = receipt.post
    self = $($event.target)
    unless self.attr("disabled")
      $http.post("/posts/#{post.id}/sms_notifications").success () ->
        fixed_alert("系统即将发送短信通知")
        self.html("系统即将发送短信通知")
        self.attr("disabled","disabled")
      .error () ->
        fixed_alert("发送失败")

  $scope.fetch_forms = (receipt) ->
    read_receipt(receipt)
    post = receipt.post
    unless post.forms
      $http.get("/posts/#{post.id}/forms").success (data) ->
        post.forms = data.forms
        form = post.forms.first()
        form.collectioned = false
        if receipt.origin
          $http.get("/forms/#{form.id}/collections").success (data) ->
            form.collections = data.collections
        $http.get("/forms/#{form.id}/collection").success (data) ->
          form.collectioned = true
          collection = data.collection
          for entity in collection
            $scope.update_form(form, entity.key, entity.value)

    height = if $("\##{receipt.id}-forms").css("height") is "auto" then "0px" else "auto"
    $("\##{receipt.id}-forms").css("height",height)


  $scope.show_collection = (receipt)->
    false

  $scope.update_form = (form, key, value) ->
    for input in form.inputs
      if input.identifier is key
        key_input = input
        break
    return unless key_input
    switch key_input.type
      when "Field::TextField", "Field::TextArea", "Field::NumberField"
        key_input.default_value = value
      when "Field::RadioButton"
        for option in key_input.options
          if option.id is value
            key_input.default_value = option.value
            break
      when "Field::CheckBox"
        for option in key_input.options
          if value.getIndex(option.id) >= 0
            option.default_selected = true
          else
            option.default_selected = false

  $scope.favoriteable = (receipt) ->
    read_receipt(receipt)
    if receipt.favorited
      $http.delete("/receipts/#{receipt.id}/favorite").success((data) ->
        receipt.favorited = false
      )
    else
      $http.post("/receipts/#{receipt.id}/favorite").success((data) ->
        receipt.favorited = true
      )
  $scope.expandable = (receipt) ->
    read_receipt(receipt)
    receipt.expanded = !receipt.expanded

  read_receipt = (receipt) ->
    unless receipt.read
      receipt.read = true
      $http.put("/receipts/#{receipt.id}/read")

]