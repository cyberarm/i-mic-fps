class IMICFPS
  class ColladaParser < Model::Parser
    def self.handles
      [:dae]
    end

    def parse
      @collada = Nokogiri::XML(File.read(@model.file_path))

      @collada.css("library_materials material").each do |material|
        parse_material(material)
      end

      @collada.css("library_geometries geometry").each do |geometry|
        parse_geometry(geometry)
      end

      @model.calculate_bounding_box(@model.vertices, @model.bounding_box)
      @model.objects.each do |o|
        @model.calculate_bounding_box(o.vertices, o.bounding_box)
      end
    end

    def parse_material(material)
      name = material.attributes["id"].value
      effect_id = material.at_css("instance_effect").attributes["url"].value

      mat = Model::Material.new(name)
      effect = @collada.at_css("[id=\"#{effect_id.sub('#', '')}\"]")

      emission = effect.at_css("emission color")
      diffuse = effect.at_css("diffuse color").children.first.to_s.split(" ").map { |c| Float(c) }

      mat.diffuse = Color.new(*diffuse[0..2])

      add_material(name, mat)
    end

    def parse_geometry(geometry)
      geometry_id = geometry.attributes["id"].value
      geometry_name = geometry.attributes["name"].value

      change_object(geometry_name)

      mesh = geometry.at_css("mesh")

      get_positions(geometry_id, mesh)
      get_normals(geometry_id, mesh)
      get_texture_coordinates(geometry_id, mesh)

      build_faces(geometry_id, mesh)
    end

    def get_positions(id, mesh)
      positions = mesh.at_css("[id=\"#{id}-positions\"]")
      array = positions.at_css("[id=\"#{id}-positions-array\"]")

      stride = Integer(positions.at_css("[source=\"##{id}-positions-array\"]").attributes["stride"].value)
      list = array.children.first.to_s.split(" ").map{ |f| Float(f) }.each_slice(stride).each do |slice|
        position = Vector.new(*slice)
        @model.current_object.vertices << position
        @model.vertices << position
      end
    end

    def get_normals(id, mesh)
      normals = mesh.at_css("[id=\"#{id}-normals\"]")
      array = normals.at_css("[id=\"#{id}-normals-array\"]")

      stride = Integer(normals.at_css("[source=\"##{id}-normals-array\"]").attributes["stride"].value)
      list = array.children.first.to_s.split(" ").map{ |f| Float(f) }.each_slice(stride).each do |slice|
        normal = Vector.new(*slice)
        @model.current_object.normals << normal
        @model.normals << normal
      end
    end

    def get_texture_coordinates(id, mesh)
    end

    def build_faces(id, mesh)
      material_name = mesh.at_css("triangles").attributes["material"].value

      mesh.at_css("triangles p").children.first.to_s.split(" ").map { |i| Integer(i) }.each_slice(3).each do |slice|
        set_material(material_name)

        face = Face.new
        face.vertices = []
        face.uvs      = []
        face.normals  = []
        face.colors   = []
        face.material = current_material
        face.smoothing= @model.smoothing

        slice.each do |index|
          face.vertices << @model.vertices[index]
          # face.uvs << @model.uvs[index]
          face.normals << @model.normals[index]
          face.colors << current_material.diffuse
        end

        @model.current_object.faces << face
        @model.faces << face
      end
    end
  end
end