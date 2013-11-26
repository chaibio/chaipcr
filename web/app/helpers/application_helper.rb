module ApplicationHelper
  def display_flashmsg(msgtype, msg)
      return "" if msg.blank?
      if msgtype == :error
      	 classstr = "errmsg"
      elsif msgtype == :notice
      	 classstr = 'noticemsg'
      elsif msgtype == :info
      	 classstr = 'infomsg'
      else
         classstr = msgtype.to_s
      end
      return "<div class='flashmsg #{classstr}'><span>#{msg}</span></div>".html_safe
  end
  
end
