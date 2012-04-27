module RelationshipsHelper

  def causality_of_this(relation)
    
    # What's the relationship type?
    @rel_type = relation.relationship_type
    
    # depending on that, create sentence
    case @rel_type       
    when nil
        @sentence = "causes"
        @css_id   = "causal_arrow"
      when "I"
        @sentence = "reduces"
        @css_id   = "inhibitory_arrow"
      when "H"
        @sentence = "includes"   
        @css_id   = "heirarchical_arrow" 
    end
    return @sentence, @css_id
  end

end
