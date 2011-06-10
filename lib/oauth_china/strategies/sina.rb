module OauthChina
  class Sina < OauthChina::OAuth
      
    def initialize(*args)
      self.consumer_options = {
        :site               => 'http://api.t.sina.com.cn',
        :request_token_path => '/oauth/request_token',
        :access_token_path  => '/oauth/access_token',
        :authorize_path     => '/oauth/authorize',
        :realm              => url
      }
      super(*args)
    end

    def name
      :sina
    end

    def user_info
      r = self.get "http://api.t.sina.com.cn/account/verify_credentials.json"
      return unless r.code == '200'
      user_hash = JSON.load(r.body)
      {
        'uid' => user_hash['id'],
        'nickname' => user_hash['screen_name'],
        'name' => user_hash['name'],
        'location' => user_hash['location'],
        'image' => user_hash['profile_image_url'],
        'description' => user_hash['description'],
        'urls' => {
          'Tsina' => user_hash['url']
        }
      }
    end
    
    def authorized?
      #TODO
    end

    def destroy
      #TODO
    end

    def add_status(content, options = {})
      options.merge!(:status => content)
      self.post("http://api.t.sina.com.cn/statuses/update.json", options)
    end

    def upload_image(content, image_path, options = {})
      options = options.merge!(:status => content, :pic => File.open(image_path, "rb")).to_options
      upload("http://api.t.sina.com.cn/statuses/upload.json", options)
    end

    

  end
end