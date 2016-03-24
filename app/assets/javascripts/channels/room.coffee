App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    $('#messages').scrollTop($('#messages')[0].scrollHeight);

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $toastContent = $('<span>'+data['message']+'</span>');
    # Called when there's incoming data on the websocket for this channel
    $('#messages').append data['message']
    $('#messages').scrollTop($('#messages')[0].scrollHeight)
    Materialize.toast($toastContent, 3000, 'rounded');

  speak: (message) ->
    @perform 'speak', message: message

  $(document).on 'keypress', '[data-behavior~=room_speaker]', (event) ->
    if event.keyCode is 13 # return = send
      App.room.speak event.target.value
      event.target.value = ""
      event.preventDefault()