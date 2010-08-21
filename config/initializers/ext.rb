class Time
  def to_cn
    self.strftime("%Y年%m月%d日")
  end
  
  def to_ss
    self.strftime("%Y-%m-%d %H:%M:%S")
  end
  
  def cn_long
    self.strftime("%Y年%m月%d日 "+(self.strftime("%p") == "AM" ? "上午" : "下午" ) + " %l:%M")   
  end
  
  def cn_num
    self.strftime("%Y-%m-%d %H:%M")   
  end
  
  def to_sss
    self.strftime("%Y_%m_%d_%H_%M_%S")
  end
  
  def relative_time
    from_time = self
    to_time =  Time.now
    distance_in_minutes = (((to_time - from_time).abs)/60).round

    case distance_in_minutes
    when 0..1            then '约一分钟以前'
    when 2..44           then "#{distance_in_minutes}分钟以前"
    when 45..89          then '约一小时以前'
    when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round}小时以前"
    when 1440..2879      then "约1天以前"
    when 2880..43199     then "#{(distance_in_minutes / 1440).round}天以前"
    else                
      self.strftime("%Y-%m-%d")
    end
  end

end

module ActiveRecord
  class Errors
    def error_messages(options = {})
      full_messages = []

      @errors.each_key do |attr|
        @errors[attr].each do |message|
          next unless message

          if attr == "base"
            full_messages << message
          else
            full_messages << I18n.t('activerecord.errors.format.separator', :default => ' ') + message
          end
        end
      end
      full_messages
    end
  end
end

class Float
  def floor_to(x)
    (self * 10**x).floor.to_f / 10**x
  end
  
  def to_n(n = 2)
    (format "%.#{n}f", self).to_f
  end
end

class Fixnum
  def to_n(n = 2)
    (format "%.#{n}f", self).to_f
  end
end

class String
  def to_js_utf16
    s = Iconv.conv("UTF-16", "UTF-8", self)
    ss = ''
    bs = s.bytes.to_a
    sequence_ok = (bs[0] == 254 && bs[1] == 255)
    bs = bs[2..-1]
    a = bs.in_groups_of 2
   
    a.each do |b1, b2|
      ss += '\u' 
      if sequence_ok
        ss += "%02x%02x" % [b1,b2]
      else
        ss += "%02x%02x" % [b2,b1]
      end
    end
    ss
  end 
  
  
  def ip2long
    ip = self
    long = 0
    ip.split(/\./).each_with_index do |b, i|
      long += b.to_i * (255 ** (4-i))
    end
    long
  end
  
  def head(n = 12)
    self.mb_chars[0..n]
  end

  def last_n(n=6)
    self[-n, n]
  end
  
  def clean_title
    self.gsub(/\[原创\]/, "").gsub(/\[原\]/, "").gsub(/\[验客\]/, "").gsub(/\t|\r|\n/, "")
  end
end

class Numeric
  def long2ip 
    long = self
    ip = []
    4.downto(1) do |i|
      ip.push(long.to_i / (255 ** i))
      long = long.to_i % (255 ** i)
    end
    ip.join(".")
  end 
end

class Array
  def to_aa
    self.map{|x| [x, self.index(x) + 1]}
  end
end

class String
  def clean
    self.gsub(/((\r|\n)*)/, '')
  end

  def filter_point_tag
    r = Regexp.new('(\[\{[^\}]+?\}\])')
    self.gsub!(r, '')
  end

  def self.uuid
    `uuidgen`.strip
  end

  def utf8_to_gb2321
    encode_convert(self, "gb2321", "UTF-8")
  end

  def gb2321_to_utf8
    encode_convert(self, "UTF-8", "gb2321")
  end
  
  def gb18030_to_utf8
    encode_convert(self, "UTF-8", "gb18030")
  end

  def utf8_to_utf16
    encode_convert(self, "UTF-16LE", "UTF-8")
  end

  def utf8?
    begin
      utf8_arr = self.unpack('U*')
      true if utf8_arr && utf8_arr.size > 0
    rescue
      false
    end
  end
  
  def clean_place
    return self if self.mb_chars.size < 3
    return "xxwojiuuimzybvegedifh" if self == "小洲村"
    self.gsub(/县$/, "").gsub(/市$/, "").gsub(/镇$/, "").gsub(/村$/, "").gsub(/省$/, "").gsub(/洲$/, "").gsub(/世博园$/, "世博")
  end

  def self.random_alphanumeric(size=16)
    (1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
  end

  def self.random_filename(n = 16)
    "#{Digest::SHA1.hexdigest("-#{String.random_alphanumeric(n)}-#{Time.now.to_s}")}"
  end
  
  def self.sha1(content)
    Digest::SHA1.hexdigest(content)
  end

  private
  def encode_convert(s, to, from)
    require 'iconv'
    begin
      converter = Iconv.new(to, from)
      converter.iconv(s)
    rescue
      s
    end
  end
end

module ApplicationHelper
 def error_messages_for(object_name, options = {})
  options = options.symbolize_keys
  object = instance_variable_get("@#{object_name}")
  if object
  unless object.errors.empty?

  error_lis = []
  object.errors.each{ |key,msg| error_lis << content_tag("li", msg) }

  content_tag("div",
  content_tag(
  options[:header_tag] || "h2",
                " 发生#{object.errors.count}个错误"
            ) +content_tag("ul", error_lis),"id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
              )
  end
 end
 end
end

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"field field-error required\">#{html_tag}</span>" }



class ActiveRecord::Base   
  def self.per_page
    20
  end
end
