# Image model
class Image
  extend Model::FileHelpers

  IMAGE_PATH = 'public/uploads'.freeze
  IMAGE_DATA_PATH = file_path('images.yml').freeze
  USER_IMAGE_DATA_PATH = file_path('user_images.yml').freeze

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

    def all
      load_data(IMAGE_DATA_PATH)
    end

    def user_image_ids(user_id)
      user_images_data = load_data(USER_IMAGE_DATA_PATH) || {}
      user_images_data[user_id]
    end

    def user_images(user_id)
      ids = user_image_ids(user_id)
      return unless ids

      images_data = load_data(IMAGE_DATA_PATH)

      ids.each_with_object({}) do |id, images|
        images[id] = images_data[id]['filename']
      end
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
      return unless valid_id?(image_id)
      image_id = image_id.to_i

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

    def valid_id?(id)
      id == id.to_i.to_s
    end
  end

  def upload
    @filename = file[:filename].gsub(/(?!\.)\W/, '-')
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
