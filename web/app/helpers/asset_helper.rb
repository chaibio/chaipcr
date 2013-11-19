module AssetHelper
  def cycle_placeholder
    "<div class='protocol droppable-cycle hide'>".html_safe+cycle_placeholder_body+"</div>".html_safe
  end
  
  def cycle_placeholder_body
        output = <<-placeholder
<div class='title'>Cycle</div>
<ul>
    <li class='droppable placeholder'></li>
</ul>
placeholder
        output.html_safe
  end
  
  def cycle_delete_confirm_msg
    "Are you sure you want to delete this cycle and all its steps?"
  end
  
  def step_delete_confirm_msg
    "Are you sure you want to delete this step?"
  end
  
  def newcycleform
     str = 
      form_tag("URL_PH", :remote=>true, :class=>"cycleform", :method=>"post")+
      "<div class='title'>".html_safe+cycleform("newcycle").html_safe+
      "</div><ul><li>".html_safe+stepform("newcycle").html_safe+
      "</li></ul></form>".html_safe
      
    return str
  end
  
  def cycleform(action)
    newcycle = (action == "newcycle");
    
    str = ""
    if action != "newcycle"
      str = form_tag("URL_PH", :remote=>true, :class=>"cycleform", :method=>"put")
    end
    str += 
    hidden_field_tag("next_component", "")+
    "<span class='cycle-name'>".html_safe+
    text_field_tag("cycle[name]", (newcycle)? "" : "NAME_PH", :class=>"textinput", :title=>"Cycle Name")+
    "</span><span class='cycle-repeat'>".html_safe+
    text_field_tag("cycle[repeat]", (newcycle)? "" : "REPEAT_PH", :class=>"textinput", :title=>"Repeat")+
    "</span>".html_safe
    
    if action != "newcycle"
      str += "<span class='cyclebuttons'>".html_safe+
             submit_tag('Save')+
             "<input type='button' class='cancel' value='Cancel'/></span></form>".html_safe
    end
    
    return str
  end
  
  def stepform(action)
    newstep = (action != "updatestep");
    str = ""
    if (action != "newcycle")
      str = form_tag("URL_PH", :remote=>true, :class=>"stepform", :method=>(newstep)? "post" : "put")
    end
    
    str +=
    hidden_field_tag("next_component", "")+
    "<div class='row-input'><span class='step-name'>".html_safe+
    text_field_tag("step[name]", (newstep)? "" : "NAME_PH", :class=>"textinput", :title=>"Step Name")+
    "</span><span class='step-temperature'>".html_safe+
    text_field_tag("step[temperature]", (newstep)? "" : "TEMPERATURE_PH", :class=>"textinput", :title=>"Temperature")+
    "</span><span class='step-hold-time'>".html_safe+
    text_field_tag("step[hold_time]", (newstep)? "" : "HOLDTIME_PH", :class=>"textinput", :title=>"Hold Time")+
    "</span></div><div class='row-ctl'>".html_safe+
    submit_tag('Save')+
    "<input type='button' class='cancel' value='Cancel'/></div>".html_safe
    
    if (action != "newcycle")
      str += "</form>".html_safe
    end
    
    return str
  end
end
