class Model < ActiveRecord::Base

  #Reads all the records
  def self.read
    @model = Model.all
    return @model
  end

  #Creates new record
  def self.create(params)
    param = Model.build_param(params,1)
    @model = Model.new(param)
    response = @model.save ? @model.success_response("Added") : @model.error_response
    return response
  end

  #Updates a record 
  def self.edit(params)
    Model.set_model(params)
    param = Model.build_param(params,2)
    response = @model.update_attributes(param) ? @model.success_response("Edited") : @model.error_response
    return response
  end

  #Deletes a record
  def self.destroy(params)
    Model.set_model(params)
    @model.destroy
    return @model.success_response("Deleted")
  end

  # Use callbacks to share common setup or constraints between actions.
  def self.set_model(params)
    @model = Model.find(params[:id])
  end

  #Builds parameter hash to handle the web request parameters.
  def self.build_param(params,index)
    param = params.to_a.reverse.drop(index)
    hash_value = Hash.new
    param.each do |value|
      hash_value["#{value.first}"] = value.last
    end
    return hash_value
  end

  #Success response hash
  def success_response(message)
    success_message = {
        "message" => "#{message} successfully.",
        "details" => self
    }
  end

  #Error response hash
  def error_response
    error_message = {
        "error" => "Error",
        "message" => self.errors
    }
  end
end
