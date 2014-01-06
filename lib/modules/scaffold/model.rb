class Model < ActiveRecord::Base

  def self.read
    @model = Model.all
    return @model
  end

  def self.create(params)
    param = Model.build_param(params)
    @model = Model.new(param)
    response = @model.save ? @model.success_response("Added") : @model.error_response
    return response
  end

  def self.edit(params)
    Model.set_model
    response = @model.update(params) ? @model.success_response("Edited") : @model.error_response
    return respose
  end

  def self.destroy(params)
    Model.set_model
    @model.destroy
    return @model.success_response("Deleted")
  end

  # Use callbacks to share common setup or constraints between actions.
  def self.set_model
    @model = Model.find(params[:id])
  end

  def self.build_param(params)
    param = params.to_a.reverse.drop(1)
    hash_value = Hash.new
    param.each do |value|
      hash_value["#{value.first}"] = value.last
    end
    return hash_value
  end

  def success_response(message)
    success_message = {
        "message" => "#{message} successfully.",
        "details" => self
    }
  end

  def error_response
    error_message = {
        "error" => "Error",
        "message" => self.errors
    }
  end
end
