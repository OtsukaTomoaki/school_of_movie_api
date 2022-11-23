class ImageService
  include CustomException

  def self.convert_binary2file!(binary)
    genrate_file(binary)
  end

  private
    def self.genrate_file(image)
      file = Tempfile.new
      file.binmode
      file.write(image)
      file.rewind
      file
    end
end