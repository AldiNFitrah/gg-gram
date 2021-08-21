require 'json'


class AssetController
  def self.serve(params)
    begin
      send_file("./public/#{params['file']}")
    rescue => exception
      [404, {"error": "file not found"}.to_json()]
    end
  end
end
