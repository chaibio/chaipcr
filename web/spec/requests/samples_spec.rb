require 'spec_helper'

describe "Samples API", type: :request do
  before(:each) do
    admin_user = create_admin_user
    post '/login', { email: admin_user.email, password: admin_user.password }
        
    @experiment = create_experiment_with_one_stage("test")
    
    post "/experiments/#{@experiment.id}/samples", {name: "test"}.to_json, http_headers
    expect(response).to be_success  
    json = JSON.parse(response.body)
    @sample = Sample.find_by_id(json["sample"]["id"])
  end
  
  describe "#all" do
    it "empty samples" do
      @sample.destroy
      get "/experiments/#{@experiment.id}/samples", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(0)
    end
    
    it "empty samples with no well layout" do
      @experiment.well_layout.destroy
      get "/experiments/#{@experiment.id}/samples", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(0)
    end
    
    it 'samples' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [1]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/samples", {name: "test1"}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      #replace well 1 with test1 sample
      post "/experiments/#{@experiment.id}/samples/#{json["sample"]["id"]}/links", {wells: [2]}.to_json, http_headers
      expect(response).to be_success
      get "/experiments/#{@experiment.id}/samples", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json[0]["sample"]["samples_wells"].length).to eq(1)
      expect(json[1]["sample"]["samples_wells"].length).to eq(1)
    end
  end
  
  describe "#create" do
    it 'valid sample' do
      post "/experiments/#{@experiment.id}/samples", {name: "test1"}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["sample"]["name"]).to eq("test1")
    end
    
    it 'sample with no name' do
      post "/experiments/#{@experiment.id}/samples", {name: nil}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["sample"]["errors"]).not_to be_nil
    end
    
    it 'with no well layout' do
      @experiment.well_layout.destroy
      post "/experiments/#{@experiment.id}/samples", {name: "test1"}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["sample"]["name"]).to eq("test1")
    end
  end
  
  describe "#update" do
    it 'sample name' do
      put "/experiments/#{@experiment.id}/samples/#{@sample.id}", {name: "test2"}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["sample"]["name"]).to eq("test2")
    end
    
    it 'invalid sample id' do
      put "/experiments/#{@experiment.id}/samples/#{@sample.id+1}", {name: "test2"}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["errors"]).not_to be_nil
    end
  end
  
  describe "#destroy" do
    it 'sample' do
      delete "/experiments/#{@experiment.id}/samples/#{@sample.id}", { :format => 'json' }
      expect(response).to be_success
    end
    
    it 'invalid sample id' do
      delete "/experiments/#{@experiment.id}/samples/#{@sample.id}", { :format => 'json' }
      expect(response).to be_success
      delete "/experiments/#{@experiment.id}/samples/#{@sample.id}", { :format => 'json' }
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["errors"]).not_to be_nil
    end
    
    it 'sample disallowed if it is linked' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells:[2]}.to_json, http_headers
      expect(response).to be_success
      delete "/experiments/#{@experiment.id}/samples/#{@sample.id}", { :format => 'json' }
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["sample"]["errors"]).not_to be_nil
    end
  end
  
  describe "#link" do    
    it 'one well' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [1]}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["sample"]["samples_wells"][0]["well_num"]).to eq(1)
    end
    
    it 'two wells' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [1, 2]}.to_json, http_headers
      expect(response).to be_success  
      json = JSON.parse(response.body)
      expect(json["sample"]["samples_wells"].length).to eq(2)
    end
    
    it 'two wells with same well num' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [1, 1]}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json["sample"]["samples_wells"].length).to eq(1)
    end
    
    it 'two wells with two calls' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [1]}.to_json, http_headers
      expect(response).to be_success  
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [2]}.to_json, http_headers
      expect(response).to be_success  
      json = JSON.parse(response.body)
      expect(json["sample"]["samples_wells"].length).to eq(2)
    end
    
    it 'another sample in the well' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [1]}.to_json, http_headers
      expect(response).to be_success
      post "/experiments/#{@experiment.id}/samples", {name: "test1"}.to_json, http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      #replace well 1 with test1 sample
      post "/experiments/#{@experiment.id}/samples/#{json["sample"]["id"]}/links", {wells: [1]}.to_json, http_headers
      expect(response).to be_success
      get "/experiments/#{@experiment.id}/samples", http_headers
      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
      expect(json[0]["sample"]["samples_wells"].length).to eq(0)
      expect(json[1]["sample"]["samples_wells"].length).to eq(1)
      expect(json[1]["sample"]["samples_wells"][0]["well_num"]).to eq(1)
    end
    
    it 'well num is invalid' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [17]}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["sample"]["samples_wells"].length).to eq(0)
      expect(json["sample"]["errors"]["samples_wells"].length).to eq(1)
    end
    
    it 'sample doesnot belong disallowed' do
      @experiment = create_experiment_with_one_stage("test1")
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells:[1]}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["sample"]["errors"]).not_to be_nil
    end
  end
  
  describe "#unlink" do
    it 'existed well' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [1]}.to_json, http_headers
      expect(response).to be_success  
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/unlinks", {wells: [1]}.to_json, http_headers
      expect(response).to be_success  
      json = JSON.parse(response.body)
      expect(json["sample"]["samples_wells"].length).to eq(0)
    end
    
    it 'notexisted well' do
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/links", {wells: [1]}.to_json, http_headers
      expect(response).to be_success  
      post "/experiments/#{@experiment.id}/samples/#{@sample.id}/unlinks", {wells: [3]}.to_json, http_headers
      expect(response.response_code).to eq(422)
      json = JSON.parse(response.body)
      expect(json["sample"]["samples_wells"].length).to eq(1)
      expect(json["sample"]["errors"]["samples_wells"].length).to eq(1)
    end
  end
end