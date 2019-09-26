# IMIC FPS Assets
## Directory Structure
* /__package__
  * /__name__
    * /model
      * model.obj
    * /scripts
      * script.rb
    * /textures
      * texture.png
    * manifest.yaml

## Manifest File
```yaml
name: "Friendly Name of Object"
model: "model.obj" # path to model relative to package/name/model/

# optional options:
# Type of collision detection to use: null, boundingbox, orientated_bb, mesh
collision: "mesh"
# Path to collision model or null to use `model`
collision_mesh: null
# Array of scripts to load, relative to package/name/scripts/
scripts: [
  "script"
]
# Array of assets to preload that this asset uses/requires
uses: [
  -
    package: "base"
    name: "door"
]
```