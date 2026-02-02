//@input SceneObject parent
//@ui {"widget":"label", "label":"Fire Aura: 1 - Right, 2 - Left"}
//@input SceneObject[] imageObject

// prend juste les deux screen Image et les fait tourner sur elle meme

//_________________________Director Setup_________________________//
script.subScene = new global.SubScene(script, script.parent);
script.subScene.OnStart = Start;
script.subScene.OnLateStart = OnLateStart;
script.subScene.OnStop = Stop;
script.subScene.SetUpdate(Update);

//__________________________Variables_____________________________//

//_________________________Director functions_____________________//

function Start() {}
function OnLateStart() {}

function Update() {
  // Rotate the fire aura images
  script.imageObject.forEach(function (imageObj) {
    var transform = imageObj.getTransform();
    var currentRotation = transform.getLocalRotation();
    // Rotate around the Z axis
    var rotationSpeed = 10; // degrees per second
    var deltaRotation = rotationSpeed * getDeltaTime();
    var newRotation = currentRotation.multiply(
      quat.fromEuler(0, 0, deltaRotation),
    );
    transform.setLocalRotation(newRotation);
  });
}

function Stop() {}

//___________________________Functions__________________________//
