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

// scaleAnim.Easing = QuadraticInOut;
function ScaleAnimUpdate(ratio) {
  var newPos = vec3.lerp(script.startPosition, script.endPosition, ratio);
  script.letterPos.getTransform().setWorldPosition(newPos);
}

scaleAnim.AddTimeCodeEvent(1, function () {});

//_________________________Director functions_____________________//

function Start() {}
function OnLateStart() {
  // var transform = script.imageObject[0].getTransform();
  // var currenScale = transform.getLocalScale();
  // print(
  //   "Current scale Z:" +
  //     currenScale.z +
  //     "Y:" +
  //     currenScale.y +
  //     "X:" +
  //     currenScale.x,
  // );
  // transform.setLocalScale(new vec3(2, 2, 2));
  // var newScale = transform.getLocalScale();
  // print("New scale Z:" + newScale.z + "Y:" + newScale.y + "X:" + newScale.x);
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
