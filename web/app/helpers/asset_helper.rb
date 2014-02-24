module AssetHelper
  def stage_placeholder
    "<div class='protocol droppable-stage hide'>".html_safe+stage_placeholder_body+"</div>".html_safe
  end
  
  def stage_placeholder_body
        output = <<-placeholder
<div class='title'>Stage</div>
<ul>
    <li class='droppable placeholder'></li>
</ul>
placeholder
        output.html_safe
  end
  
  def stage_delete_confirm_msg
    "Are you sure you want to delete this stage and all its steps?"
  end
  
  def step_delete_confirm_msg
    "Are you sure you want to delete this step?"
  end
  
  def newstageform
     str = 
      form_tag("URL_PH", :remote=>true, :class=>"stageform", :method=>"post")+
      "<div class='title'>".html_safe+stageform("newstage").html_safe+
      "</div><ul><li>".html_safe+stepform("newstage").html_safe+
      "</li></ul></form>".html_safe
      
    return str
  end
  
  def stageform(action)
    newstage = (action == "newstage");
    
    str = ""
    if !newstage
      str = form_tag("URL_PH", :remote=>true, :class=>"stageform", :method=>"put")
    end
    str += 
    hidden_field_tag("next_component", "")+
    "<span class='stage-name'>".html_safe+
    label_tag("Stage Name", "Stage Name")+
    text_field_tag("stage[name]", (newstage)? "" : "NAME_PH", :class=>"textinput", :title=>"Stage Name")+
    "</span><span class='stage-num-cycles'>".html_safe+
    label_tag("Num of Cycles")+
    text_field_tag("stage[num_cycles]", (newstage)? "" : "NUM_CYCLES_PH", :class=>"textinput", :title=>"Num of Cycles")+
    "</span>".html_safe
    
    if !newstage
      str += "<span class='stagebuttons'>".html_safe+
             submit_tag('Save')+
             "<input type='button' class='cancel' value='Cancel'/></span></form>".html_safe
    end
    
    return str
  end
  
  def stepform(action)
    newstep = (action != "updatestep");
    str = ""
    if (action != "newstage")
      str = form_tag("URL_PH", :remote=>true, :class=>"stepform", :method=>(newstep)? "post" : "put")
    end
    
    str +=
    hidden_field_tag("next_component", "")+
    "<div class='row-input'><span class='step-name'>".html_safe+
    label_tag("Step Name", "Step Name")+
    text_field_tag("step[name]", (newstep)? "" : "NAME_PH", :class=>"textinput", :title=>"Step Name")+
    "</span><span class='step-temperature'>".html_safe+
    label_tag("Temperature")+
    text_field_tag("step[temperature]", (newstep)? "" : "TEMPERATURE_PH", :class=>"textinput", :title=>"Temperature")+
    "</span><span class='step-hold-time'>".html_safe+
    label_tag("Hold Time", "Hold Time")+
    text_field_tag("step[hold_time]", (newstep)? "" : "HOLDTIME_PH", :class=>"textinput", :title=>"Hold Time")+
    "</span></div><div class='row-ctl'>".html_safe+
    submit_tag('Save')+
    "<input type='button' class='cancel' value='Cancel'/></div>".html_safe
    
    if (action != "newstage")
      str += "</form>".html_safe
    end
    
    return str
  end
end
