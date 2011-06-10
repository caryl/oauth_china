module OauthChina
  class Qzone < OauthChina::OAuth

    def initialize(*args)
      self.consumer_options = {
        :site => "http://openapi.qzone.qq.com",
        :request_token_path  => "/oauth/qzoneoauth_request_token",
        :access_token_path   => "/oauth/qzoneoauth_access_token",
        :authorize_path      => "/oauth/qzoneoauth_authorize",
        :http_method         => :get,
        :scheme              => :query_string,
        :nonce               => nonce,
        :realm               => url
      }
      super(*args)
    end

    def name
      :qzone
    end
    
    #overload
    def authorize_url
      @authorize_url ||= request_token.authorize_url(:oauth_callback => URI.encode(callback), :oauth_consumer_key => self.key)
    end

    #XXX:HACK for Qzone!
    def authorize(options = {})
      return unless self.access_token.nil?
      if vericode = options.delete(:oauth_vericode)
        self.consumer.options[:access_token_path] = self.consumer_options[:access_token_path] + "?oauth_vericode=#{vericode}"
      end
      super(options)
    end

    def user_info(openid = uid)
      return unless openid
      r = self.get "http://openapi.qzone.qq.com/user/get_user_info?openid=#{openid}"
      return unless r.code == '200'
      user_hash = JSON.load(r.body)
        {
          'uid' => openid,
          'nickname' => user_hash['nickname'],
          'name' =>  user_hash['nickname'],
          'image' => user_hash['figureurl'],
          'urls' => {
            'figureurl_1' => user_hash['figureurl_1'],
            'figureurl_2' => user_hash['figureurl_2'],
          }
        }
    end
    
    def nonce
      Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')[0, 32]
    end
      
    def authorized?
      #TODO
    end

    def destroy
      #TODO
    end

    def add_status(content, options = {})
      #TODO
      options.merge!(:action => 1, :title => content, :titleurl => options[:url])
      self.post("http://openapi.qzone.qq.com/feeds/add_feeds", options)
    end

    #TODO
    def upload_image(content, image_path, options = {})
      add_status(content, options)
    end
    
  end
end