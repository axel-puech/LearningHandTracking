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
    var deltaRot = quat.fromEulerAngles(0, 0, 0.1); // Rotate 1 degree around Z axis
    var newRot = deltaRot.multiply(currentRotation);
    transform.setWorldRotation(newRot);
  });
}

function Stop() {}

//___________________________Functions__________________________//
