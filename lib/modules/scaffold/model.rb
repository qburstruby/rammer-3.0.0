=begin
**************************************************************************
* The MIT License (MIT)

* Copyright (c) 2013-2014 QBurst Technologies Inc.

* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.

**************************************************************************
=end

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
