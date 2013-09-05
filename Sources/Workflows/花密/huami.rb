require 'rubygems'
require 'openssl'

module Huami

  STR1 = "snow"
  STR2 = "kise"
  STR3 = "sunlovesnow1990090127xykab"

  def self.huami(key, password)
    md5one    = md5_hmac(key, password)
    md5two    = md5_hmac(STR1, md5one)
    md5three  = md5_hmac(STR2, md5one)

    # 转换大小写
    rule    = md5three.split('')
    source  = md5two.split('')
    for i in (0..31)
      if STR3.include? rule[i]
        source[i] = source[i].upcase
      end
    end

    # 保证首字符为字母
    if is_digit(source[0])
      code16 = "K" + source[1..15].join()
    else
      code16 = source[0..15].join()
    end

    return code16
  end

  def self.md5_hmac(key, password)
    digest = OpenSSL::Digest::Digest.new('md5')
    return OpenSSL::HMAC.hexdigest(digest, key, password)
  end

  def self.is_digit(string)
    return string.strip =~ /^[0-9]$/
  end

end