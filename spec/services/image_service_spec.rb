require 'rails_helper'

RSpec.describe ImageService, type: :service do
  let!(:image) {
    fixture_file_upload("images/sample_1.jpeg", 'image/jpeg').read
  }

  describe "convert_binary2file!" do
    it "Tempfileが返されること" do
      image_file = ImageService.convert_binary2file!(image)
      expect(image_file.read).to eq image
    end
  end
end