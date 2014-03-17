class AARPCC::Renderer

  def initialize(controller_instance)
    @controller_instance = controller_instance
  end

  def supported_content_type?(content_type)
    content_type == 'application/json'
  end

  def render_result(result)
    @controller_instance.content_type  = "application/json"
    @controller_instance.response_body = result.to_json
    @controller_instance.status        = "200"
  end


  def render_aarpcc_error(e)
    @controller_instance.content_type  = "text/plain"
    @controller_instance.response_body = e.message
    @controller_instance.status        = e.http_status_code.to_s
    @controller_instance.headers['X-AARPCC-Error-Code']    = e.application_error_code.to_s
    @controller_instance.headers['X-AARPCC-Error-Message'] = e.message
  end


  def render_internal_error(e)
    @controller_instance.content_type  = "text/plain"
    @controller_instance.response_body = e.message
    @controller_instance.status        = "500"
    @controller_instance.headers['X-AARPCC-Error-Code']    = 0
    @controller_instance.headers['X-AARPCC-Error-Message'] = e.message
  end

end