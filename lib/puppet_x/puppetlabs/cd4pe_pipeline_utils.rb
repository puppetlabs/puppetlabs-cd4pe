# Provides a set of method for manipulating CD4PE Pipelines
module CD4PEPipelineUtils
  def self.add_destination_to_stage(stages, destination, stage_name, add_stage_after, autopromote, trigger_condition)
    existing_stage_idx = CD4PEPipelineUtils.get_stage_index_by_name(stages, stage_name)
    if existing_stage_idx.nil?
      # We're creating a new stage
      new_stage = {
        destinations: [destination],
        stageName: stage_name,
        triggerOn: autopromote,
      }
      new_stage[:triggerCondition] = trigger_condition if autopromote
      if add_stage_after.nil?
        # Since there is no stage dep, just add the stage to the end of the pipeline
        stages << new_stage
      else
        dep_stage_idx = CD4PEPipelineUtils.get_stage_index_by_name(stages, add_stage_after)
        stages.insert(dep_stage_idx + 1, new_stage)
      end
    else
      # Add the job destination to the existing stage
      stages[existing_stage_idx][:destinations] << destination
      stages[existing_stage_idx][:triggerOn] = autopromote
      stages[existing_stage_idx][:triggerCondition] = trigger_condition if autopromote
    end
    stages
  end

  def self.get_stage_index_by_name(stages, stage_name)
    matched_stages = stages.each_index.select { |i| stages[i].fetch(:stageName, nil) == stage_name }
    if matched_stages.length > 1
      raise Puppet::Error, "Found multiple stages for name: #{stage_name}. Give pipeline stages unique names and try again."
    end
    matched_stages[0]
  end
end
