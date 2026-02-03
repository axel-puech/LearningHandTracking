//@input SceneObject parent
//@ui {"widget":"separator"}
//@ui {"widget":"label", "label":"Fire Aura: 1 - Right, 2 - Left"}
//@input SceneObject[] imageObject
//@ui {"widget":"separator"}
//@input float scaleDuration = 2.0
//@input float speedRotation = 0.1

//_________________________Director Setup_________________________//
script.subScene = new global.SubScene(script, script.parent);
script.subScene.OnStart = Start;
script.subScene.OnLateStart = OnLateStart;
script.subScene.OnStop = Stop;
script.subScene.SetUpdate(Update);

//__________________________Variables_____________________________//
//________Listener________//
// 0 = right, 1 = left
const targetReachedListener = script.subScene.CreateListener(
  "targetReachedEvent",
  UnscaleFireAura,
);

var isLeftFireAuraActive = true;
var isRightFireAuraActive = true;

//__________________________Animations____________________________//
// SCALE ANIMATION
var scaleAnim = new global.Animation(
  script.parent,
  script.scaleDuration,
  ScaleAnimUpdate,
);
scaleAnim.Easing = BounceOut;

function ScaleAnimUpdate(ratio) {
  var scaleValue = ratio; // Scale to 1
  script.imageObject.forEach(function (imageObj) {
    var transform = imageObj.getTransform();
    transform.setLocalScale(new vec3(scaleValue, scaleValue, scaleValue));
  });
}

scaleAnim.AddTimeCodeEvent(1, function () {});

// UNSCALE ANIMATION
var elementToUnscale = null;

var unscaleAnim = new global.Animation(
  script.parent,
  script.scaleDuration,
  UnscaleAnimUpdate,
);
unscaleAnim.Easing = BounceIn;

function UnscaleAnimUpdate(ratio) {
  var scaleValue = 1 - ratio; // Unscale to 0
  var transform = elementToUnscale.getTransform();
  transform.setLocalScale(new vec3(scaleValue, scaleValue, scaleValue));
}

unscaleAnim.AddTimeCodeEvent(1, function () {});

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
    var deltaRot = quat.fromEulerAngles(0, 0, script.speedRotation);
    var newRot = deltaRot.multiply(currentRotation);
    transform.setWorldRotation(newRot);
  });
}

function Stop() {
  isLeftFireAuraActive = true;
  isRightFireAuraActive = true;
  scaleAnim.Reset();
}

//___________________________Functions__________________________//

function UnscaleFireAura(value) {
  if (value === 0 && isRightFireAuraActive) {
    print("Unscale Right Fire Aura");
    // Unscale right fire aura
    elementToUnscale = script.imageObject[1];
    unscaleAnim.Start();
    isRightFireAuraActive = false;
  } else if (value === 1 && isLeftFireAuraActive) {
    print("Unscale Left Fire Aura");
    // Unscale left fire aura
    elementToUnscale = script.imageObject[0];
    unscaleAnim.Start();
    isLeftFireAuraActive = false;
  }
}
