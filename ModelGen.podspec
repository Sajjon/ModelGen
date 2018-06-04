Pod::Spec.new do |s|

  s.name         = "ModelGen"
  s.version      = "0.3.0"
  s.summary      = "A Swift tool to generate Models for many languages, based on a JSON-Schema and a Stencil template"

  s.description  = <<-DESC
                   A Swift tool to generate Models for many languages, based on a JSON-Schema and a Stencil template
                   DESC

  s.homepage     = "https://github.com/hebertialmeida/ModelGen"
  s.license      = "MIT"
  s.author       = { "Heberti Almeida" => "hebertialmeida@gmail.com" }
  s.social_media_url = "https://twitter.com/hebertialmeida"

  s.source       = { :http => "https://github.com/hebertialmeida/ModelGen/archive/0.3.0.zip" }
  s.preserve_paths = '*'
  s.exclude_files  = '**/file.zip'
end
