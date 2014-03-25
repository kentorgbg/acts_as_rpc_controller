class AARPCC::Logger

	def initialize(controller_instance)
		@controller_instance = controller_instance
	end


	def log(&block)
		total, result = benchmark{ block.call }
		access_log(total)
		critical_log(total, result) if result.kind_of? Exception
	end


	def benchmark(&block)
		start  = Time.now
		result = call_and_rescue(&block)
		total  = Time.now - start
		[total, result]
	end


	def call_and_rescue(&block)
		block.call
	rescue Exception => e
		e
	end


	def access_log(total)
		request  = @controller_instance.request
		logger   = @controller_instance.class.aarpcc_declaration.access_logger
		error    = @controller_instance.headers['X-AARPCC-Error-Message']
		message  = [].tap do |m|
			#m << Time.now.strftime("%Y-%m-%d %H:%M:%S.%L%z")
			m << @controller_instance.status
			m << sprintf("%.3fs", total)
			m << "#{request.request_method} #{request.path}"
			m << request.parameters.inspect
			m << error unless error.blank?
		end
		
		logger.info message.join(" | ")
	end


	def critical_log(total, e)
		request  = @controller_instance.request
		logger   = @controller_instance.class.aarpcc_declaration.critical_logger
		logger.error <<-STR
### INTERNAL ERROR ############################
Request:    #{request.request_method} #{request.path}
Error:      #{e.class.to_s} - #{e.message}
Parameters: #{request.parameters.inspect}
Backtrace:
#{(e.backtrace[0...30] + ["..."]).join("\n")}
STR
	end
end