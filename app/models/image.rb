class Image
  extend Model::FileHelpers

  IMAGE_PATH = 'public/uploads'
  IMAGE_DATA_PATH = file_path('images.yml')
  USER_IMAGE_DATA_PATH = file_path('user_images.yml')

  attr_reader :file, :user_id, :images_data, :user_image_data, :image_id

  def initialize(file, user_id)
    @file = file
    @user_id = user_id
    @images_data = self.class.load_data(IMAGE_DATA_PATH) || {}
    @user_image_data = self.class.load_data(USER_IMAGE_DATA_PATH) || {}
    @image_id = id
  end

  class << self
    def fetch(*ids)
      data = load_data(IMAGE_DATA_PATH)
      imgs = ids.each_with_object([]) { |id, arr| arr << data[id]['filename'] }
      imgs.size > 1 ? imgs : imgs.first
    end
  end

  def upload
    @filename = file[:filename]
    save_image_data
    save_user_image_data

    FileUtils.cp(file[:tempfile].path, File.join(IMAGE_PATH, @filename))
  end

  def id
    image_id || images_data.keys.max.to_i + 1
  end

  private

  def save_image_data
    images_data[image_id] = { 'filename' => @filename, 'user_id' => user_id }
    self.class.save(images_data, IMAGE_DATA_PATH)
  end

  def save_user_image_data
    user_image_data[user_id] = image_id
    self.class.save(user_image_data, USER_IMAGE_DATA_PATH)
  end
end
