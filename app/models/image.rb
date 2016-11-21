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

    def delete_user_images(user_id)
      images_data = load_data(IMAGE_DATA_PATH) || {}
      user_images_data = load_data(USER_IMAGE_DATA_PATH) || {}
      return unless user_images_data[user_id]

      user_images_data[user_id].each do |image_id|
        image_data = images_data.delete(image_id)
        filename = image_data['filename']
        File.delete(File.join(IMAGE_PATH, filename))
      end

      user_images_data.delete(user_id)

      save(user_images_data, USER_IMAGE_DATA_PATH)
      save(images_data, IMAGE_DATA_PATH)
    end

    def delete(image_id)
      images_data = load_data(IMAGE_DATA_PATH) || {}
      user_images_data = load_data(USER_IMAGE_DATA_PATH) || {}
      return unless images_data[image_id]

      user_id = images_data[image_id]['user_id']

      File.delete(File.join(IMAGE_PATH, images_data[image_id]['filename']))
      images_data.delete(image_id)
      user_images_data[user_id].delete(image_id)

      save(user_images_data, USER_IMAGE_DATA_PATH)
      save(images_data, IMAGE_DATA_PATH)
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
    user_imgs = user_image_data[user_id]

    user_imgs ? user_imgs << image_id : user_image_data[user_id] = [image_id]
    self.class.save(user_image_data, USER_IMAGE_DATA_PATH)
  end
end
