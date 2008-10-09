module Net::HTTPHeader

  def set_form_data(params, sep = '&')
    self.body = params.map { |k,v|
      case v
        when Array: v.map { |v2| "#{urlencode(k.to_s)}=#{urlencode(v2.to_s)}" }.join(sep)
        else "#{urlencode(k.to_s)}=#{urlencode(v.to_s)}"
      end
    }.join(sep)
    self.content_type = 'application/x-www-form-urlencoded'
  end

  # Files have the format of {:name => {:filename => 'testing.txt', :content => 'Your content goes here, bub.'}}
  def set_multipart_form_data(params, sep = '&')
    boundary = '--------------the_smurfs_are_eating_your_lunch_12581827'

    files = []
    vars = []

    params.each { |key,val|
      if val.is_a?(Array)
        val.each { |v2|
          str, is_file = v2.is_a?(Hash) ? multipart_format( {:name => key}.reverse_merge(v2)) : multipart_format( :name => key, :content => v2 )
          (is_file ? files : vars) << "--#{boundary}\r\n#{str}"
        }
      else
        str, is_file = val.is_a?(Hash) ? multipart_format( {:name => key}.reverse_merge(val)) : multipart_format( :name => key, :content => val )
        (is_file ? files : vars) << "--#{boundary}\r\n#{str}"
      end
    }

    self.body = "#{files.join}#{vars.join}--#{boundary}--"

    self.content_type = "multipart/form-data; boundary=#{boundary}"
  end

  def multipart_format(hash)
    str = %'Content-Disposition: form-data; name="#{hash[:name]}"'
    str = %'#{str}; filename="#{hash[:filename]}"\r\nContent-Type: #{hash[:type] ? hash[:type] : MIME::Types.type_for(hash[:filename])}' if hash[:filename]
    [%'#{str}\r\n\r\n#{hash[:content]}\r\n', !hash[:filename].blank?]
  end
end
