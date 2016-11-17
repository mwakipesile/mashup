module Model
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

    def save(data, path)
      File.open(path, 'w') { |file| file.write(data.to_yaml) }
    end
  end
end
