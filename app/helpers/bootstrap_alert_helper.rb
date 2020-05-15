module BootstrapAlertHelper
  def bootstrap_class_for(msg_type)
    {
      success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info'
    }.stringify_keys[msg_type.to_s] || msg_type.to_s
  end

  def bootstrap_alert(message, msg_type = 'success')
    content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)}", role: 'alert')
  end
end
