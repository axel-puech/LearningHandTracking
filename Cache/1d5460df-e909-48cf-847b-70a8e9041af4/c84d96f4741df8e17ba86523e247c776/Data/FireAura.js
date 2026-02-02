//@input SceneObject parent
//@ui {"widget":"label", "label":"Fire Aura: 1 - Right, 2 - Left"}
//@input SceneObject[] imageObject
//@input float scaleDuration = 2.0

// prend juste les deux screen Image et les fait tourner sur elle meme

//_________________________Director Setup_________________________//
script.subScene = new global.SubScene(script, script.parent);
script.subScene.OnStart = Start;
script.subScene.OnLateStart = OnLateStart;
script.subScene.OnStop = Stop;
script.subScene.SetUpdate(Update);

//__________________________Variables_____________________________//

//__________________________Animations____________________________//
// SCALE ANIMATION
var scaleAnim = new global.Animation(
  script.parent,
  script.scaleDuration,
  ScaleAnimUpdate,
);

scaleAnim.Easing = BounceInOut;
function ScaleAnimUpdate(ratio) {
  var scaleValue = ratio; // Scale to 1
  script.imageObject.forEach(function (imageObj) {
    var transform = imageObj.getTransform();
    transform.setLocalScale(new vec3(scaleValue, scaleValue, scaleValue));
  });
}

scaleAnim.AddTimeCodeEvent(1, function () {});

//_________________________Director functions_____________________//

function Start() {}
function OnLateStart() {
  scaleAnim.Start();
}

function Update() {
  // Rotate the fire aura images
  script.imageObject.forEach(function (imageObj) {
    var transform = imageObj.getTransform();
    var currentRotation = transform.getLocalRotation();
    var deltaRot = quat.fromEulerAngles(0, 0, 0.1); // Rotate 0.1 degree around Z axis
    var newRot = deltaRot.multiply(currentRotation);
    transform.setWorldRotation(newRot);
  });
}

function Stop() {}

//___________________________Functions__________________________//
