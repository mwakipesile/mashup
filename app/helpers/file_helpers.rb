# Model helpers
module Model
  # File helpers
  module FileHelpers
    def base_path
      File.expand_path('../../..', __FILE__)
    end

    def load_data(file_path)
      YAML.load_file(file_path)
    end

    def file_path(file, dir = 'data')
      data_path = File.join(base_path, dir)
      File.join(data_path, file)
    end

    def data_path(file, dir = nil)
      path = dir ? File.join('data', dir) : 'data'
      file_path(file, path)
    end

    def save(data, path)
      File.open(path, 'w') { |file| file.write(data.to_yaml) }
    end
  end
end
